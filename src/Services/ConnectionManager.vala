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
	private int sock;
	private SSH2.Session session;

	public Object db_type {
		get { return _db_type; }
		set { _db_type = value; }
	}

	public Gda.Connection? connection { get; set; default = null; }
	public Gda.DataModel? output_select;

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
		debug (data["port"]);
		var connection_string = (db_type as DataBaseType).connection_string (data);

		try {
			connection = Gda.Connection.open_from_string (null, connection_string, null, Gda.ConnectionOptions.NONE);
		} catch (Error e) {
			ssh_tunnel_close ();
			throw e;
		}

		if (connection.is_opened ()) {
			ssh_tunnel_close ();
			connection.close ();
		}
	}

	public void open () throws Error {
		var connection_string = (db_type as DataBaseType).connection_string (data);

		try {
			connection = Gda.Connection.open_from_string (null, connection_string, null, Gda.ConnectionOptions.NONE);
		} catch (Error e) {
			throw e;
		}
	}

	public void ssh_tunnel_init () throws Error {
		try {
			ssh_tunnel_open ();
		}
		catch (Error e) {
			throw e;
		}
	}

	private void ssh_tunnel_open () throws Error {
		debug ("Opening tunnel");
		
		var home_dir = Environment.get_home_dir ();
		var keyfile1 = home_dir + "/.ssh/id_rsa.pub";
		var keyfile2 = home_dir + "/.ssh/id_rsa";

		var ssh_host = Posix.inet_addr (data["ssh_host"]);
		var ssh_username = data["ssh_username"];
		var ssh_password = data["ssh_password"];
		var ssh_port = data["ssh_port"] != "" ? (uint16) (data["ssh_port"]).hash () : 22;
		var host = data["host"] != "" || data["host"] != "127.0.0.1" ? data["host"] : "localhost";
		var host_port = data["port"] != "" ? int.parse (data["port"]) : 9000;

		Quark q = Quark.from_string ("ssh-error-str");
		
		var rc = SSH2.init (SSH2.InitFlags.NONE);
		if (rc != SSH2.Error.NONE) {
			debug ("Libssh2 initialization failed (%d)", rc);
			throw new Error.literal (q, 1, _("Libssh2 initialization failed (%d)").printf (rc));
		}

		sock = Posix.socket (Posix.AF_INET, Posix.SOCK_STREAM, 0);
		if (sock == -1) {
			debug ("Error opening Socket");
			throw new Error.literal (q, 1, _("Error opening Socket"));
		}

		Posix.SockAddrIn sin = Posix.SockAddrIn ();
		sin.sin_family = Posix.AF_INET;
		sin.sin_port = Posix.htons (ssh_port);
		sin.sin_addr.s_addr = ssh_host;
		if (Posix.connect (sock, &sin, sizeof (Posix.SockAddrIn)) != 0) {
			debug ("Failed to Connect via SSH");
			throw new Error.literal (q, 1, _("Failed to Connect via SSH"));
		}

		session = SSH2.Session.create<bool> ();
		if (session.handshake(sock) != SSH2.Error.NONE) {
			debug ("Failed to establish SSH session");
			throw new Error.literal (q, 1, _("Failed to establish SSH session"));
		}

		var fingerprint = session.get_host_key_hash(SSH2.HashType.SHA1);
		debug ("Fingerprint: ");
		for (var i = 0; i < 20; i++) {
			stdout.printf ("%02X ", fingerprint[i]);
		}
		stdout.printf ("\n");

		bool auth_key = false;
		var userauthlist = session.list_authentication (ssh_username.data);
		debug ("Authentication methods: %s", userauthlist);
		
		if ("publickey" in userauthlist) {
			auth_key = true;
		}

		if (auth_key) {
			if (session.auth_publickey_from_file (ssh_username, keyfile1, keyfile2, ssh_password) != SSH2.Error.NONE) {
				ssh_tunnel_close ();
				throw new Error.literal (q, 1, _("Error! Public Key doesn't match."));
			}
		} else {
			ssh_tunnel_close ();
			throw new Error.literal (q, 1, _("No SSH Authentication methods available."));
		}

		SSH2.Channel? channel = null;
		if (session.authenticated && (channel = session.open_channel ()) == null) {
			ssh_tunnel_close ();
			throw new Error.literal (q, 1, _("Unable to open SSH Session."));
		} else {
			debug ("SESSION OPEN!!!");
		}

        if (channel.request_pty ("vanilla".data) != SSH2.Error.NONE) {
			ssh_tunnel_close ();
			throw new Error.literal (q, 1, _("Failed requesting virtual terminal."));
        }

        if (channel.start_shell () != SSH2.Error.NONE) {
			ssh_tunnel_close ();
			throw new Error.literal (q, 1, _("Unable to request Shell."));
		}

		//  SSH2.Listener? listener = null;
		//  int bound_port;
		//  if ((listener = session.forward_listen_ex (host, host_port, out bound_port, 1)) == null) {
		//  	ssh_tunnel_close ();
		//  	throw new Error.literal (q, 1, _("Unable to create Port Forwarding."));
		//  } else {
		//  	debug ("Port forwarded");
		//  }

		//  data["port"] = host_port.to_string ();

		//  forward_port.begin (session, channel, listener);

		//  yield;
		//  channel = listener.accept ();
		//  while ((channel = listener.accept ()) != null) {
		//  	debug ("Channel accepted");
		//  }
		//  if (channel == null) {
		//  	ssh_tunnel_close ();
		//  	throw new Error.literal (q, 1, _("Could not accept connection! Check your Server Log"));
		//  } else {
		//  	debug ("SESSION OPEN!!!");
		//  }

		//  SSH2.Channel? channel_forward = null;
		//  channel = listener.accept ();
		//  if (channel == null) {
		//  	ssh_tunnel_close ();
		//  	throw new Error.literal (q, 1, _("Unable to open SSH Session."));
		//  } else {
		//  	debug ("SESSION OPEN!!!");
		//  }

		//  debug (bound_port.to_string ());
		//  data["port"] = host_port.to_string ();

		debug ("No errors so far");
	}

	//  private async void forward_port (SSH2.Session? session, SSH2.Channel? channel, SSH2.Listener? listener) throws ThreadError {
		//  yield;
		//  while (listener.accept () != null) {
		//  	yield;
		//  }
		//  while ((channel = listener.accept ()) != null) {
		//  	debug ("Channel accepted");
		//  }
	//  }

	public void ssh_tunnel_close () {
		if (session == null) {
			return;
		}

		session = null;
		Posix.close (sock);
		SSH2.exit ();
		debug ("SSH tunnel closed");
	}

	public int run_query (string query) throws Error requires (connection.is_opened ()) {
		return connection.execute_non_select_command (query);
	}

	public Gda.DataModel? run_select (string query) throws Error {
		return connection.execute_select_command (query);
	}

	public async Gee.HashMap<string, string> init_connection (Sequeler.Services.ConnectionManager connection) throws ThreadError {
		var output = new Gee.HashMap<string, string> ();
		output["status"] = "false";
		SourceFunc callback = init_connection.callback;

		new Thread <void*> (null, () => {
			bool result = true;
			string msg = "";

			try {
				connection.open ();
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
