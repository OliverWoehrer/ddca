#!/usr/bin/env python3

import os
import subprocess
import yaml
import threading
from docopt import docopt
from datetime import datetime
from time import sleep
import psutil

import signal
import sys
import fcntl


class RPAConnection:
	def __init__(self):
		self._host = None
		self._deadline = None
		self._streams = {}
		self._rpa_server = None
		self._username = None
		self._identity = None
	
	@property
	def Host(self):
		return self._host
	
	@Host.setter
	def Host(self, value):
		self._host = value

	@property
	def Username(self):
		return self._username
	
	@Username.setter
	def Username(self, value):
		self._username = value

	@property
	def Identity(self):
		return self._identity
	
	@Identity.setter
	def Identity(self, value):
		self._identity = value
		
	@property
	def RPAServer(self):
		return self._rpa_server
	
	@RPAServer.setter
	def RPAServer(self, value):
		self._rpa_server = value

	@property
	def Deadline(self):
		return self._deadline
	
	@Deadline.setter
	def Deadline(self, value):
		self._deadline = value

	@property
	def Streams(self):
		return self._streams
	
	def LaodFromDict(self, dct):
		if ("identity" in dct):
			self.Identity = dct["identity"]
		if ("username" in dct):
			self.Username = dct["username"]
		if ("rpa_server" in dct):
			self.RPAServer = dct["rpa_server"]
		self.Host = dct["host"]
		self.Deadline = dct["deadline"]
		for name,url in dct["videostreams"].items():
			if("not available" in url):
				continue
			self.Streams[name] = url
	
	def DumpToDict(self):
		data = {}
		data["username"] = self.Username
		if(self.Identity != None):
			data["identity"] = self.Identity
		data["rpa_server"] = self.RPAServer
		data["deadline"] = self.Deadline
		data["host"] = self.Host
		data["videostreams"] = self.Streams
		return data
	
	def CreateSSHCommand(self, arguments):
		id_arg = ""
		if(self.Identity != None):
			id_arg = "-i" + self.Identity + " "

		cmd = "ssh IDARG -tt -o ProxyCommand=\"ssh IDARG -W %h:%p USERNAME@RPASERVER\" USERNAME@HOST".replace("IDARG", id_arg)
		cmd = cmd.replace("USERNAME", self.Username).replace("HOST", self.Host).replace("RPASERVER", self.RPAServer) + " " + arguments + " "
		#print(cmd)
		return cmd
	
	def CopyFileToHost(self, src, dest):
		id_arg = ""
		if(self.Identity != None):
			id_arg = "-i " + self.Identity + " "
		scp_cmd = "scp IDARG -oProxyCommand=\"ssh IDARG -W %h:%p USERNAME@RPASERVER\" " + src + " USERNAME@HOST:" + dest
		scp_cmd = scp_cmd.replace("IDARG", id_arg)
		scp_cmd = scp_cmd.replace("USERNAME", self.Username)
		scp_cmd = scp_cmd.replace("RPASERVER", self.RPAServer)
		scp_cmd = scp_cmd.replace("HOST", self.Host)
		subprocess.run(scp_cmd, shell=True)
	
	def RunCommand(self, cmd, ssh_args=""):
		ssh_cmd = self.CreateSSHCommand(ssh_args + " \"" + cmd + " \"")
		subprocess.run(ssh_cmd, shell=True)
	
	def RunShell(self):
		subprocess.run(self.CreateSSHCommand("-YC -tt"), shell=True)

class RPAClient:
	UNABLE_TO_CONNECT_MSG = """\
Error: Unable to connect to RPA server SERVER!
Did you add an SSH key to your TILab account?\
"""
	def __init__(self, rpa_server, username, identity=None):
		self._rpa_server = rpa_server
		self._username = username
		self._identity = identity
		self._lock = threading.Lock()
		self._lock.acquire(blocking=False)
		self._connection = None
		self._proc = None
	
	def _ssh_command(self):
		cmd = ["ssh", "-tt"]
		if(self._identity != None):
			cmd += ["-i",  self._identity]
		cmd += [self._username+"@"+self._rpa_server]
		return cmd
	
	def CopyFileToServer(self, src, dest):
		id_arg = ""
		if(self._identity != None):
			id_arg = "-i " + self._identity + " "
		scp_cmd = "scp IDARG " + src + " USERNAME@RPASERVER:" + dest
		scp_cmd = scp_cmd.replace("IDARG", id_arg)
		scp_cmd = scp_cmd.replace("USERNAME", self._username)
		scp_cmd = scp_cmd.replace("RPASERVER", self._rpa_server)
		subprocess.run(scp_cmd, shell=True)
	
	def ServerStatus(self):
		try:
			rpa_status_cmd = self._ssh_command() + ["rpa status"]
			r = subprocess.run(rpa_status_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding="utf-8")
		except Exception as ex:
			return RPAClient.UNABLE_TO_CONNECT_MSG.replace("SERVER", self._rpa_server)
		return r.stdout.strip()
	
	def RequestHost(self, host=None):
		def RequestHostThread(host=None):
			rpa_cmd = "rpa -V MESSAGE-SET=vlsi-yaml "
			if (host != None):
				rpa_cmd += "want-host " + host
			else:
				rpa_cmd += "lock"

			ssh_cmd = self._ssh_command()  + [rpa_cmd]

			try:
				proc = subprocess.Popen(ssh_cmd, shell=False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, encoding="utf-8")
				print("connected to " + self._rpa_server)
				self._proc = proc
			except Exception as ex:
				#print(ex)
				print(RPAClient.UNABLE_TO_CONNECT_MSG.replace("SERVER", self._rpa_server))
				self._lock.release()
				return
			
			try:
				yml_str = ""
				while(True):
					line = proc.stdout.readline()
					#print(line.rstrip())
					if (line == ""):
						#print("slot expired ... exiting")
						break
					elif (line.rstrip() == "---"):
						dct = yaml.load(yml_str, Loader=yaml.SafeLoader)
						if("status" not in dct):
							print("Invalid respone from server!")
							exit(1)
						if(dct["status"] == "ASSIGNED"):
							self._connection = RPAConnection()
							self._connection.LaodFromDict(dct)
							self._connection.RPAServer = self._rpa_server
							self._connection.Username = self._username
							self._connection.Identity = self._identity
							self._lock.release()
						elif(dct["status"] == "WAITING"):
							print("No free host available, you have been added to the waiting queue!")
						elif(dct["status"] == "EXTENDED"):
							self._connection.Deadline = dct["deadline"]
						elif(dct["status"] == "INFO"):
							print(dct["reason"])
						else:
							print(dct)
						yml_str = ""
					else:
						yml_str += line.rstrip() + "\n"
						
			except:
				pass
			
		
		self._checkout_thread = threading.Thread(target = RequestHostThread, args=(host,))
		self._checkout_thread.start()

	def ReleaseHost(self):
		try:
			self._proc.terminate()
		except:
			pass

	def WaitForHost(self):
		self._lock.acquire()
		if(self._connection == None):
			raise Exception("Unable to acquire remote host")


	@property
	def Connection(self):
		if(self._connection == None):
			raise Exception("No host assigned yet")
		return self._connection


class ConnectionLockFile:
	def __init__(self, path):
		self._path = path
		self._lock_file = None
	
	def Exists(self):
		return os.path.exists(connection_lock_file_path)
	
	def Create(self):
		self._lock_file = open(self._path, "x")
	
	def OpenRead(self):
		self._lock_file = open(self._path, "r")
	
	def Write(self, connection=None):
		if (connection == None):
			lock_data = {}
		else:
			lock_data = connection.DumpToDict()
		lock_data["pid"] = os.getpid()
		
		fcntl.flock(self._lock_file.fileno(), fcntl.LOCK_EX)
		self._lock_file.seek(0)
		self._lock_file.write(yaml.dump(lock_data))
		self._lock_file.flush()
		fcntl.flock(self._lock_file.fileno(), fcntl.LOCK_UN)
	
	def ReadConnection(self):
		delelte_msg = "I will delete the lock file now. You can try rerunning this command."
	
		fcntl.flock(self._lock_file.fileno(), fcntl.LOCK_EX)
		dct = yaml.safe_load(self._lock_file.read())
		fcntl.flock(self._lock_file.fileno(), fcntl.LOCK_UN)
		
		#empty file, maybe just a bad coincidence --> try again
		if (dct == None):
			sleep(0.5)
			fcntl.flock(self._lock_file.fileno(), fcntl.LOCK_EX)
			dct = yaml.safe_load(self._lock_file.read())
			fcntl.flock(self._lock_file.fileno(), fcntl.LOCK_UN)
		
		if (dct == None):
			print("Error: Something went wrong! The connection lock file is empty!")
			print(delelte_msg)
			self.Remove()
			exit(1)
		if ("pid" not in dct):
			print("Error: Something went wrong! Invalid connection lock file is empty!")
			print(delelte_msg)
			self.Remove()
			exit(1)
		
		pid = dct["pid"]
		if (not psutil.pid_exists(pid)):
			print("Error: Master process seems to be dead!")
			print(delelte_msg)
			self.Remove()
			exit(1)
		
		if (not "host" in dct):
			print("No host assigned yet ... exiting")
			exit()
		
		connection = RPAConnection()
		connection.LaodFromDict(dct)
		return connection

	def Close(self):
		self._lock_file.close()

	def Remove(self):
		os.remove(self._path)


usage_msg = """
This tool simplifies the access to the remote lab environment in the TILab used
in the DDCA lab course. The first call to rpa_shell (master process) automat-
ically acquires a lab PC slot and optionally opens the video streams, programs
the FPGA, executes a command or opens an interactive shell. Subsequent execu-
tions of rpa_shell will use the same connection as long as the lab PC is
assigned to you or until you terminate the master process.

If neither -n nor a command (<CMD>) is specified, rpa_shell opens an interactive
shell by default. If -n is supplied to the master process a simple menu will be
shown, that waits for user input.

To access the TILab computers you have to specify your username. You can do this
via the -u argument or using a config file named 'rpa_cfg.yml' which must be 
placed in the same directory as the rpa_shell script itself. To create this file
simply execute rpa_shell without a username and follow the instructions.

Optionally you can also specify which identity file (i.e., private key file) the 
rpa_shell tools should use to establish the SSH connection  (-i argument passed 
to the ssh command). You can do this via the -i command line option or using the
(optional) identity entry in the config file. If you don't know what this 
feature is for, you will probably not need it. To specify an identity add the
following line to the config file:

identity: PATH_TO_YOUR_IDENTITY_FILE 

The config file may also contain an (optional) entry named 'stream_cmd' to
precisely specify the command that should be used to open the streams. The 
command is: 
  ffplay -fflags nobuffer -flags low_delay -framedrop -hide_banner \\
         -loglevel error -autoexit

Usage:
  rpa_shell.py [-c HOST -p SOF -u USER -i ID -d] [-a | -s STREAM] [-n | <CMD>]
  rpa_shell.py [-u USER -i ID -t]
  rpa_shell.py --scp [-u USER -i ID] <LOCAL_SRC> [<REMOTE_DEST>]
  rpa_shell.py -h | -v

Options:
  -h --help      Show this help screen
  -v --version   Show version information
  -n --no-shell  Don't open a shell.
  -c HOST        Request access to a specific host.
  -t             Show status information about the rpa system, i.e., available
                 hosts usage, etc. (executes rpa status and shows the result).
  -a             Open all video streams
  -s STREAM      Open one particular stream (target, signal or oszi)
  -p SOF         Download the specified SOF_FILE file to the FPGA board.
  -u USER        The username for the SSH connection. If omitted the username 
                 must be contained in the rpa_cfg.yml config file.
  -i ID          The identity file to use for the SSH connection.
  -d             Video stream debug mode (don't redirect the stream player's
                 output to /dev/null) 
  --scp          Copies the file specified by <LOCAL_SRC> to the lab, at the 
                 location specified by <REMOTE_DEST>. If <REMOTE_DEST> is 
                 omitted the file will be placed in your home directory.
"""

stream_debug = False
default_stream_cmd = "ffplay -fflags nobuffer -flags low_delay -framedrop -hide_banner -loglevel error -autoexit"
stream_cmd = default_stream_cmd

def cfg_streaming(dbg, cmd=None):
	global stream_ffplay, stream_debug, stream_cmd
	stream_debug = dbg

	if(cmd != None):
		stream_cmd = cmd
	stream_ffplay = stream_cmd

def open_stream(url):
	global stream_ffplay, stream_debug, stream_cmd
	cmd = stream_cmd
	cmd += " " + url
	if (stream_debug == False):
		cmd += " 2>/dev/null 1>/dev/null "
	cmd += "&"
	os.system(cmd)


rpa_server = "ssh.tilab.tuwien.ac.at"
script_dir = os.path.dirname(os.path.realpath(__file__))

connection_lock_file_name = ".connection.rpa"
connection_lock_file_path = script_dir + "/" + connection_lock_file_name
connnection_lock_file = None


cfg_file_name = "rpa_cfg.yml"
cfg_file_path =  script_dir + "/" + cfg_file_name

def signal_handler(sig, frame):
	global is_master_process, client, lock
	if(client != None):
		client.ReleaseHost()
		if (lock != None):
			lock.Close()
			lock.Remove()
	try:
		os.remove(connection_lock_file_path)
	except:
		pass

	sys.exit(0)

def load_cfg(path):
	cfg = {"username": None, "identity": None, "stream_cmd":None}
	try:
		with open(path, "r") as f:
			cfg.update(yaml.load(f.read(), Loader=yaml.SafeLoader))
	except Exception as ex:
		return cfg
	return cfg


def interactive_ui(connection):
	action = None

	stream_msgs = []
	streams_seq = ["target", "signal", "oszi"]
	stream_key_map = {}
	
	idx = 1
	for s in streams_seq:
		if(s in connection.Streams):
			stream_msgs += ["  " + str(idx) + ": open video stream '" + s + "'"]
			stream_key_map[str(idx)] = s
		idx += 1
	
	for s in connection.Streams.keys():
		if (s not in streams_seq):
			stream_msg += ["  " + str(idx) + ": open video stream '" + s + "'"]
			stream_key_map[str(idx)] = s
		idx += 1
	
	stream_msg = "\n".join(stream_msgs)
	
	#stream_map = {}
	#for name,url in connection.Streams:
		
		
	while (True):
		os.system("clear")
		msg = """\
This is the master process for your connection to HOST.
Terminating this process will terminate ALL open connections to this host.
Your lock expires at DEADLINE.
Available commands:
  i: open interactive shell
STREAMS
  q: quit (terminates all open connections)\
"""			
		msg = msg.replace("HOST", connection.Host)
		msg = msg.replace("DEADLINE", connection.Deadline)
		msg = msg.replace("STREAMS", stream_msg)
		
		print(msg)
		print("Enter command >> ", end="", flush=True)
		r = subprocess.run("read -t 1 -N 1; echo $REPLY", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
		action = r.stdout.decode("utf-8").strip()
		
		if(action == "q"):
			print()
			break
		if(action == "i"):
			print()
			connection.RunShell()
		
		if (action in stream_key_map):
			stream_name = stream_key_map[action]
			url = connection.Streams[stream_name]
			print("opening stream " + stream_name + ": " + url)
			open_stream(url)
		
		#if(action == "")

is_master_process = False
client = None
lock = None

def main():
	global is_master_process, client, lock
	options = docopt(usage_msg, version="1.1.1")
	#print(options)
	
	cfg = load_cfg(cfg_file_path)
	cfg_streaming(dbg=options["-d"],cmd=cfg["stream_cmd"])

	if (options["-u"] != None):
		cfg["username"] = options["-u"]
	
	username = cfg["username"]
	if (username == None):
		print("You did not specify a TILab username!")
		username = input("Enter your username: ")
		while(True):
			response = input("Do you want me to create a config file and add this username? [y/n] ")
			response = response.strip().lower()
			if (response in ["y", "n"]):
				if (response == "y"):
					with open(cfg_file_path, "x") as f:
						f.write("username: " + username + "\n")
						f.write("stream_cmd: " + default_stream_cmd)
				break
			print("Invalid response, type 'y' or 'n'!")
	
	
	if (options["-i"] != None):
		cfg["identity"] = options["-i"]
	
	if(options["-t"]):
		client = RPAClient(rpa_server, username, identity=cfg["identity"])
		print(client.ServerStatus())
		exit(0)
	
	if (options["--scp"]):
		client = RPAClient(rpa_server, username, identity=cfg["identity"])
		dest = options["<REMOTE_DEST>"]
		if (dest == None):
			dest = ""
		client.CopyFileToServer(options["<LOCAL_SRC>"], dest)
		exit(0)
	
	is_master_process = False
	connection = None
	lock = ConnectionLockFile(connection_lock_file_path)

	if (lock.Exists()):
		lock.OpenRead()
		connection = lock.ReadConnection()
		if (options["-c"] != None):
			if (not connection.Host.startswith(options["-c"])):
				print("Error: There already exists a connection to " +
					connection.Host + 
					". If you want to connect to " +
					options["-c"] +
					" close this connection first.")
				exit(1)
		if (username != connection.Username):
			print("Error: There already exists a connection using a different username '" + connection.Username + "'")
			
	else:
		is_master_process = True
		signal.signal(signal.SIGINT, signal_handler)

		try:
			lock.Create()
		except:
			print("Unable to create connection lock file")
			exit(1)

		lock.Write()

		client = RPAClient(rpa_server, username, identity=cfg["identity"])
		client.RequestHost(options["-c"])
		try:
			client.WaitForHost()
		except:
			try: lock.Remove() 
			except: pass
			exit(1)
		connection = client.Connection
		print(">>> Acquired lock on host " + connection.Host + " <<<")
		lock.Write(connection)

	if (options["-p"] != None):
		sof_file = os.path.basename(options["-p"])
		connection.RunCommand("mkdir -p ~/.rpa_shell && rm -f ~/.rpa_shell/*.sof")
		connection.CopyFileToHost(options["-p"], ".rpa_shell/")
		connection.RunCommand("remote.py -p .rpa_shell/"+sof_file)
		
	if (options["-a"]):
		sleep(0.5)
		for name, url in connection.Streams.items():
			print("opening stream " + name + ": " + url)
			open_stream(url)
	
	if (options["-s"] != None):
		name = options["-s"]
		url = connection.Streams.get(name, None)
		if(url == None):
			print(name + " does not identify a stream")
		else:
			print("opening stream " + name + ": " + url)
			open_stream(url)
	
	if (options["<CMD>"] != None):
		connection.RunCommand(options["<CMD>"], ssh_args="-tt")
	elif (not options["--no-shell"]):
		if(is_master_process):
			print(
"""\
>>> Close the shell using Ctrl+D or by executing 'exit'. <<<
>>> CAUTION: This is the master process! <<<
>>> Closing this shell will terminate all open connections! <<<\
""")
		else:
			print(">>> Close the shell using Ctrl+D or by executing 'exit' <<<")
		connection.RunShell()
	
	if (options["--no-shell"] and is_master_process):
		interactive_ui(connection)
	
	if(is_master_process):
		try:
			client.ReleaseHost()
			lock.Close()
			lock.Remove()
		except: pass

if(__name__ == "__main__"):
	main()

