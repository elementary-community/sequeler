/*
* Copyright (c) 2011-2018 Alecaddd (http://alecaddd.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alessandro "Alecaddd" Castellani <castellani.ale@gmail.com>
*/

public class Sequeler.Services.ConnectionManager : Object {
	public weak Sequeler.Window window { get; construct; }
	public Gee.HashMap<string, string> data { get; construct; }
	private Object _db_type;

	public signal void ssh_tunnel_ready ();

	public Object db_type {
		get { return _db_type; }
		set { _db_type = value; }
	}

	public Gda.Connection? connection { get; set; default = null; }
	public Gda.DataModel? output_select;

	enum Auth {
		NONE,
		PASSWORD,
		PUBLICKEY
	}

	public ConnectionManager (Sequeler.Window window, Gee.HashMap<string, string> data) {
		Object (
			window: window,
			data: data
		);

		if (data ["password"] == null) {
			data ["password"] = "";

			var loop = new MainLoop ();
			password_mngr.get_password_async.begin (data["id"], (obj, res) => {
				try {
					data ["password"] = password_mngr.get_password_async.end (res);
				} catch (Error e) {
					debug ("Unable to get the password from libsecret");
				}
				loop.quit ();
			});

			loop.run ();
		}

		switch (data ["type"]) {
			case "MySQL":
				db_type = new Sequeler.Services.Types.MySQL ();
			break;
			case "MariaDB":
				db_type = new Sequeler.Services.Types.MySQL ();
			break;
			case "PostgreSQL":
				db_type = new Sequeler.Services.Types.PostgreSQL ();
			break;
			case "SQLite":
				db_type = new Sequeler.Services.Types.SQLite ();
			break;
		}
	}

	public void test () throws Error {
		var connection_string = (db_type as DataBaseType).connection_string (data);
		debug("connection string %s", connection_string);

		try {
			connection = Gda.Connection.open_from_string (null, connection_string, null, Gda.ConnectionOptions.NONE);
		} catch (Error e) {
			ssh_tunnel_close (null, -1, -1, -1);
			throw e;
		}

		if (connection.is_opened ()) {
			ssh_tunnel_close (null, -1, -1, -1);
			connection.close ();
		}
	}

	public void open () throws Error {
		var connection_string = (db_type as DataBaseType).connection_string (data);
		debug("connection string %s", connection_string);

		try {
			connection = Gda.Connection.open_from_string (null, connection_string, null, Gda.ConnectionOptions.NONE);
		} catch (Error e) {
			throw e;
		}
		debug("open ends");
	}

	public void ssh_tunnel_init (bool is_real) throws Error {
		try {
			ssh_tunnel_open (is_real);
		}
		catch (Error e) {
			debug (e.message);
			throw e;
		}
	}

	private void ssh_tunnel_open (bool is_real) throws Error {
		debug ("Opening tunnel");

		
		//  Quark q = Quark.from_string ("ssh-error-str");
		var home_dir = Environment.get_home_dir ();
		var keyfile1 = home_dir + "/.ssh/id_rsa.pub";
		var keyfile2 = home_dir + "/.ssh/id_rsa";

		// SSH credentials if password authentication is required
		var username = data["ssh_username"];
		var password = data["ssh_password"];
		// SSH HOST address and Port
		var server_ip = data["ssh_host"];
		var server_port = data["ssh_port"] != "" ? (uint16) (data["ssh_port"]).hash () : 22;
		// The IP address where the DB is available on your SSH
		var local_listenip = data["host"] != "" ? data["host"] : "127.0.0.1";
		// The Port used by the DB on your SSH host
		uint16 local_listenport = data["port"] != "" ? (uint16) int.parse (data["port"]) : 9000;
		// Default vars for TCPIP Tunnelling
		var remote_desthost = "127.0.0.1";
		var remote_destport = 3306;

		var rc = SSH2.init (0);
		if (rc != SSH2.Error.NONE) {
			debug ("libssh2 initialization failed (%d)", rc);
			return;
		}

		/* Connect to SSH server */
		var sock = Posix.socket (Posix.AF_INET, Posix.SOCK_STREAM, Posix.IPProto.TCP);
		if (sock == -1) {
			debug ("Failed to open socket");
			return;
		}

		Posix.SockAddrIn sin = Posix.SockAddrIn();
		sin.sin_family = Posix.AF_INET;
		sin.sin_addr.s_addr = Posix.inet_addr (server_ip);
		sin.sin_port = Posix.htons (server_port);
		if (Posix.connect (sock, &sin, sizeof (Posix.SockAddrIn)) != 0) {
			debug ("Failed to connect!");
			return;
		}

		/* Create a session instance */
		var session = SSH2.Session.create<bool> ();

		/* ... start it up. This will trade welcome banners, exchange keys,
		* and setup crypto, compression, and MAC layers
		*/
		rc = session.handshake (sock);
		if (rc != SSH2.Error.NONE) {
			debug ("Error when starting up SSH session: %d", rc);
			return;
		}

		/* At this point we haven't yet authenticated.  The first thing to do
		* is check the hostkey's fingerprint against our known hosts Your app
		* may have it hard coded, may go to a file, may present it to the
		* user, that's your call
		*/
		var fingerprint = session.get_host_key_hash (SSH2.HashType.SHA1);
		debug ("Fingerprint: ");
		for (int i = 0; i < 20; i++) {
			debug ("%02X ", fingerprint[i]);
		}

		/* check what authentication methods are available */
		int auth_pw = 0;
		var userauthlist = session.list_authentication (username.data);
		debug ("Authentication methods: %s", userauthlist);
		if ("password" in userauthlist) {
			auth_pw |= Auth.PASSWORD;
		}

		if ("publickey" in userauthlist) {
			auth_pw |= Auth.PUBLICKEY;
		}

		if ((auth_pw & Auth.PASSWORD) != 0) {
			if (session.auth_password (username, password) != SSH2.Error.NONE) {
				debug ("Authentication by password failed.");
				ssh_tunnel_close (null, sock, -1, -1);
				return;
			}
		} else if ((auth_pw & Auth.PUBLICKEY) != 0) {
			if (session.auth_publickey_from_file (username,
												keyfile1,
												keyfile2,
												password
											) != SSH2.Error.NONE) {
				debug ("Authentication by public key failed!");
				ssh_tunnel_close (null, sock, -1, -1);
				return;
			}
			debug ("Authentication by public key succeeded.");
		} else {
			debug ("No supported authentication methods found!");
			ssh_tunnel_close (null, sock, -1, -1);
			return;
		}

		var listensock = Posix.socket (Posix.AF_INET, Posix.SOCK_STREAM, Posix.IPProto.TCP);
		if (listensock == -1) {
			debug ("failed to open listen socket");
			ssh_tunnel_close (null, sock, listensock, -1);
			return;
		}

		debug ("listensock %d", listensock);

		sin = Posix.SockAddrIn ();
		sin.sin_family = Posix.AF_INET;
		sin.sin_addr.s_addr = Posix.inet_addr (local_listenip);
		sin.sin_port = Posix.htons (local_listenport);

		var sockopt = 1;
		Posix.setsockopt (listensock, Linux.Socket.SOL_SOCKET, Linux.Socket.SO_REUSEADDR, &sockopt, (Posix.socklen_t) sizeof (int)); 
		if (Posix.bind (listensock, &sin, sizeof (Posix.SockAddrIn)) == -1) {
			debug ("Failed to bind!");
			ssh_tunnel_close (null, sock, listensock, -1);
			return;
		}

		if (Posix.listen (listensock, 2) == -1) {
			debug ("Failed to listen!");
			ssh_tunnel_close (null, sock, listensock, -1);
			return;
		}

		debug ("Waiting for TCP connection on %s:%d...", local_listenip, local_listenport);

		bool signal_launched = false;
		while (true) {
			debug ("Waiting for remote connection");

			if (!is_real || !signal_launched) {
				signal_launched = true;
				ssh_tunnel_ready ();
			}

			var forwardsock = Posix.accept (listensock, null, null);

			debug ("forwardsock %d", forwardsock);

			if (forwardsock == -1) {
				debug ("Failed to accept!");
				ssh_tunnel_close (null, sock, listensock, forwardsock);
				return;
			}

			debug ("Forwarding connection from %s:%d here to remote %s:%d", local_listenip, local_listenport, remote_desthost, remote_destport);

			var channel = session.direct_tcpip (remote_desthost, remote_destport, local_listenip, local_listenport);
			if (channel == null) {
				debug ("Could not open the direct-tcpip channel! (Note that this can be a problem at the server! Please review the server logs.)");
				ssh_tunnel_close (session, sock, listensock, forwardsock);
				return;
			}

			session.blocking = false;

			uint8[] buf = new uint8[16384];
			while (true) {
				Posix.fd_set fds;
				Posix.FD_ZERO( out fds);
				Posix.FD_SET(forwardsock, ref fds);
				Posix.timeval tv = { 0, 100000};
				var res = Posix.select(forwardsock + 1, &fds, null, null, tv);
				if (-1 == res) {
					stderr.printf("Error on select!\n");
					direct_shutdown(session, forwardsock);
					break;
				}
				if (res > 0  && Posix.FD_ISSET(forwardsock, fds) > 0) {
					var len = Posix.recv(forwardsock, buf, 16384, 0);
					if (len < 0) {
						stderr.printf("Error reading from the forwardsock!\n");
						direct_shutdown(session, forwardsock);
						break;
					} else if (0 == len) {
						stderr.printf("The client at %s:%d disconnected!\n",
							local_listenip, local_listenport);
						direct_shutdown(session, forwardsock);
						break;
					}
					ssize_t wr = 0;
					ssize_t i = 0;
					do {
						i = channel.write(buf[0:len]);
						if (i < 0) {
							stderr.printf("Error writing on the SSH channel: %s\n", i.to_string());
							direct_shutdown(session, forwardsock);
							break;
						}
						wr += i;
					} while(i > 0 && wr < len);
				}
				while (true) {
					ssize_t len = channel.read(buf);
					if (SSH2.Error.AGAIN == len)
						break;
					else if (len < 0) {
						stderr.printf("Error reading from the SSH channel: %d\n", (int)len);
						direct_shutdown(session, forwardsock);
						break;
					}
					ssize_t wr = 0;
					while (wr < len) {
						ssize_t i = Posix.send(forwardsock, buf[wr:buf.length], len - wr, 0);
						if (i <= 0) {
							stderr.printf("Error writing on the forwardsock!\n");
							direct_shutdown(session, forwardsock);
							break;
						}
						wr += i;
					}
					if (channel.eof() != SSH2.Error.NONE) {
						stderr.printf("The remote client at %s:%d disconnected!\n",
										  remote_desthost, remote_destport);
						direct_shutdown(session, forwardsock);
						break;
					}
				}
			}
		}
	}

	public void ssh_tunnel_close (SSH2.Session? session, int sock, int listensock, int forwardsock) {
		Posix.close (listensock);
		Posix.close (forwardsock);

		if (session != null) {
			session.disconnect ("Client disconnecting normally\n");
		}

		Posix.close (sock);
		SSH2.exit ();
	}

	public void direct_shutdown (SSH2.Session? session, int forwardsock) {
		session.blocking = true;
		Posix.close (forwardsock);
	}

	public int run_query (string query) throws Error requires (connection.is_opened ()) {
		return connection.execute_non_select_command (query);
	}

	public Gda.DataModel? run_select (string query) throws Error {
		return connection.execute_select_command (query);
	}

	public async Gee.HashMap<string, string> init_connection (Sequeler.Services.ConnectionManager connection_manager) throws ThreadError {
		var output = new Gee.HashMap<string, string> ();
		output["status"] = "false";
		SourceFunc callback = init_connection.callback;

		new Thread <void*> (null, () => {
			bool result = true;
			string msg = "";

			try {
				connection_manager.open ();
				debug("pass init connection");
			}
			catch (Error e) {
				result = false;
				msg = e.message;
			}

			Idle.add((owned) callback);
			output["msg"] = msg;
			output["status"] = result.to_string ();

			return null;
		});

		yield;

		return output;
	}

	public async Gda.DataModel? init_select_query (string query) throws ThreadError {
		Gda.DataModel? result = null;
		SourceFunc callback = init_select_query.callback;
		var error = "";

		new Thread <void*> (null, () => {
			try {
				result = run_select (query);
			}
			catch (Error e) {
				error = e.message;
				result = null;
			}
			Idle.add((owned) callback);
			return null;
		});

		yield;

		if (error != "") {
			query_warning (error);
			return null;
		}

		return result;
	}

	public async int init_query (string query) throws ThreadError {
		int output_query = 0;
		SourceFunc callback = init_query.callback;
		var error = "";

		new Thread <void*> (null, () => {
			int result = 0;
			try {
				result = run_query (query);
			}
			catch (Error e) {
				error = e.message;
				result = 0;
			}
			Idle.add((owned) callback);
			output_query = result;
			return null;
		});

		yield;

		if (error != "") {
			query_warning (error);
			return 0;
		}

		return output_query;
	}

	public void query_warning (string message) {
		var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Error!"), message, "dialog-error", Gtk.ButtonsType.NONE);
		message_dialog.transient_for = window;
		
		var suggested_button = new Gtk.Button.with_label ("Close");
		message_dialog.add_action_widget (suggested_button, Gtk.ResponseType.ACCEPT);

		message_dialog.show_all ();
		if (message_dialog.run () == Gtk.ResponseType.ACCEPT) {}
		
		message_dialog.destroy ();
	}
}
