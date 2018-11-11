[CCode (cheader_filename = "libssh2.h>\ntypedef LIBSSH2_USERAUTH_PUBLICKEY_SIGN_FUNC((*libssh2_userauth_publickey_sign_delegate));\ntypedef LIBSSH2_IGNORE_FUNC((*libssh2_ignore_delegate));\ntypedef LIBSSH2_DEBUG_FUNC((*libssh2_debug_delegate));\ntypedef LIBSSH2_DISCONNECT_FUNC((*libssh2_disconnect_delegate));\ntypedef LIBSSH2_PASSWD_CHANGEREQ_FUNC((*libssh2_passwd_changereq_delegate));\ntypedef LIBSSH2_MACERROR_FUNC((*libssh2_macerror_delegate));\ntypedef LIBSSH2_X11_OPEN_FUNC((*libssh2_x11_open_delegate));\ntypedef LIBSSH2_USERAUTH_KBDINT_RESPONSE_FUNC((*libssh2_userauth_kbdint_response_delegate));\ntypedef LIBSSH2_RECV_FUNC((*libssh2_recv_func_delegate));\ntypedef LIBSSH2_SEND_FUNC((*libssh2_send_func_delegate));\n#include <libssh2.h")]
namespace SSH2 {
	namespace Version {
		[CCode (cname = "HAVE_LIBSSH2_AGENT_API")]
		public const int AGENT_API;
		[CCode (cname = "HAVE_LIBSSH2_VERSION_API")]
		public const int API;
		[CCode (cname = "LIBSSH2_COPYRIGHT")]
		public const string COPYRIGHT;
		[CCode (cname = "HAVE_LIBSSH2_KNOWNHOST_API")]
		public const int KNOWNHOST_API;
		[CCode (cname = "LIBSSH2_VERSION_MAJOR")]
		public const int MAJOR;
		[CCode (cname = "LIBSSH2_VERSION_MINOR")]
		public const int MINOR;
		/**
		 * This is the numeric version of the libssh2 version number, meant for
		 * easier parsing and comparions by programs.
		 *
		 * This will always follow this syntax: 0xXXYYZZ
		 * Where XX, YY and ZZ are the main version, release and patch numbers in
		 * hexadecimal (using 8 bits each). All three numbers are always
		 * represented using two digits. 1.2 would appear as "0x010200" while
		 * version 9.11.7 appears as "0x090b07".
		 *
		 * This 6-digit (24 bits) hexadecimal number does not show pre-release
		 * number, and it is always a greater number in a more recent release. It
		 * makes comparisons with greater than and less than work.
		 */
		[CCode (cname = "LIBSSH2_VERSION_NUM")]
		public const int NUM;
		[CCode (cname = "LIBSSH2_VERSION_PATCH")]
		public const int PATCH;
		[CCode (cname = "LIBSSH2_SFTP_VERSION", cheader_filename = "libssh2_sftp.h")]
		public const int SFTP;
		/**
		 * This is the date and time when the full source package was created.
		 *
		 * The timestamp is not stored in the source code repo, as the timestamp is
		 * properly set in the tarballs by the maketgz script.
		 *
		 * The format of the date should follow this template:
		 *
		 * "Mon Feb 12 11:35:33 UTC 2007"
		 */
		[CCode (cname = "LIBSSH2_TIMESTAMP")]
		public const string TIMESTAMP;
		[CCode (cname = "LIBSSH2_VERSION")]
		public const string STRING;
		[CCode (cname = "libssh2_version")]
		public unowned string check (int req_version_num = NUM);
	}
	[CCode (cname = "LIBSSH2_AGENT", free_function = "libssh2_agent_free", has_type_id = false)]
	[Compact]
	public class Agent {
		/**
		 * Connect to an ssh-agent.
		 */
		[CCode (cname = "libssh2_agent_connect")]
		public Error connect ();
		/**
		 * Close a connection to an ssh-agent.
		 */
		[CCode (cname = "libssh2_agent_disconnect")]
		public Error disconnect ();
		/**
		 * Request an ssh-agent to list identities.
		 */
		[CCode (cname = "libssh2_agent_list_identities")]
		public Error list_identities ();
		/**
		 * Traverse the internal list of public keys.
		 * @param prev Pass NULL to get the first one. Or pass a poiner to the
		 * previously returned one to get the next.
		 * @return 0 if a fine public key was returned, 1 if end of public keys, or
		 * negative on errors
		 */
		[CCode (cname = "libssh2_agent_get_identity")]
		public int next (out unowned AgentKey? result, AgentKey? prev);
		/**
		 * Do publickey user authentication with the help of ssh-agent.
		 */
		[CCode (cname = "libssh2_agent_userauth")]
		public Error user_auth (string username, AgentKey identity);
	}
	[CCode (cname = "struct libssh2_agent_publickey", has_type_id = false)]
	[Compact]
	public class AgentKey {
		/**
		 * Public key blob
		 */
		[CCode (array_length_cname = "blob_len")]
		public uint8[] blob;
		/**
		 * Comment in printable format
		 */
		public string? comment;
	}
	[CCode (cname = "LIBSSH2_CHANNEL", has_type_id = false, free_function = "libssh2_channel_free")]
	[Compact]
	public class Channel {
		[CCode (cname = "LIBSSH2_CHANNEL_FLUSH_EXTENDED_DATA")]
		public const int FLUSH_EXTENDED_DATA;
		[CCode (cname = "LIBSSH2_CHANNEL_FLUSH_ALL")]
		public const int FLUSH_ALL;
		[CCode (cname = "LIBSSH2_CHANNEL_PACKET_DEFAULT")]
		public const int PACKET_DEFAULT;
		/**
		 * Maximum size to allow a payload to compress to, plays it safe by falling short of spec limits
		 */
		[CCode (cname = "LIBSSH2_PACKET_MAXCOMP")]
		public const int PACKET_MAX_COMP;
		/**
		 * Maximum size to allow a payload to deccompress to, plays it safe by allowing more than spec requires
		 */
		[CCode (cname = "LIBSSH2_PACKET_MAXDECOMP")]
		public const int PACKET_MAX_DECOMP;
		/**
		 * Maximum size for an inbound compressed payload, plays it safe by overshooting spec limits
		 */
		[CCode (cname = "LIBSSH2_PACKET_MAXPAYLOAD")]
		public const int PACKET_MAX_PAYLOAD;
		[CCode (cname = "LIBSSH2_CHANNEL_MINADJUST")]
		public const int MIN_ADJUST;
		[CCode (cname = "LIBSSH2_CHANNEL_WINDOW_DEFAULT")]
		public const int WINDOW_DEFAULT;
		public bool blocking {
			[CCode (cname = "libssh2_channel_set_blocking")]
			set;
		}
		/**
		 * The exit code raised by the process running on the remote host at the other end of the named channel.
		 *
		 * Note that the exit status may not be available if the remote end has not yet set its status to closed.
		 */
		public int exit_status {
			[CCode (cname = "libssh2_channel_get_exit_status")]
			get;
		}
		/**
		 * Close an active data channel.
		 *
		 * In practice this means sending an SSH_MSG_CLOSE packet to the remote host which serves as instruction that no further data will be sent to it. The remote host may still send data back until it sends its own close message in response. To wait for the remote end to close its connection as well, follow this command with {@link wait_closed}.
		 */
		[CCode (cname = "libssh2_channel_close")]
		public Error close ();
		/**
		 * Check if the remote host has sent an EOF status for the selected stream.
		 * @return 1 if the remote host has sent EOF, otherwise 0. Negative on failure.
		 */
		[CCode (cname = "libssh2_channel_eof")]
		public int eof ();
		/**
		 * Flush the read buffer for a given channel instance.
		 *
		 * Individual substreams may be flushed by number or using one of the provided macros.
		 */
		[CCode (cname = "libssh2_channel_flush_ex")]
		public Error flush (int streamid = 0);
		[CCode (cname = "libssh2_channel_flush_stderr")]
		public Error flush_stderr ();
		/**
		 * Get the remote exit signal
		 * @param exit_signal the exit signal (without leading "SIG"). If the remote program exited cleanly, the referenced string will be set to null.
		 * @param error_message the error message (if provided by remote server).
		 * @param lang_tag the language tag (if provided by remote server).
		 */
		[CCode (cname = "libssh2_channel_get_exit_signal")]
		public Error get_exit_signal ([CCode (array_length_type = "size_t")] out char[]? exit_signal, [CCode (array_length_type = "size_t")] out char[]? error_message, [CCode (array_length_type = "size_t")] out char[]? lang_tag);
		/**
		 * Check if data is available
		 *
		 * Check to see if data is available in the channel's read buffer. No attempt is made with this method to see if packets are available to be processed.
		 */
		[CCode (cname = "libssh2_poll_channel_read")]
		public bool is_data_avilable (int extended);
		[CCode (cname = "libssh2_channel_read")]
		public ssize_t read ([CCode (array_length_type = "size_t")] uint8[] buf);
		[CCode (cname = "libssh2_channel_read_stderr")]
		public ssize_t read_stderr ([CCode (array_length_type = "size_t")] uint8[] buf);
		/**
		 * Read data from a channel stream
		 *
		 * Attempt to read data from an active channel stream.
		 * @param stream_id All channel streams have one standard I/O substream (0), and may have up to 2^32 extended data streams. The SSH2 protocol currently defines a stream ID of 1 to be the stderr substream.
		 * @return Actual number of bytes read or negative on failure. A return value of zero (0) can in fact be a legitimate value and only signals that no payload data was read. It is not an error.
		 */
		[CCode (cname = "libssh2_channel_read_ex")]
		public ssize_t read_stream (int stream_id, [CCode (array_length_type = "size_t")] uint8[] buf);
		/**
		 * Adjust the channel window
		 *
		 * If the amount to be adjusted is less than {@link MIN_ADJUST} and not forced the adjustment amount will be queued for a later packet.
		 *
		 * @param window the new size of the receive window (as understood by remote end).
		 */
		[CCode (cname = "libssh2_channel_receive_window_adjust2")]
		public Error receive_window_adjust (ulong adjustment, bool force, out uint window);
		/**
		 * Request a PTY on an established channel.
		 *
		 * Note that this does not make sense for all channel types and may be ignored by the server despite returning success.
		 * @param term Terminal emulation (e.g. vt102, ansi, etc...)
		 * @param mode Terminal mode modifier values
		 * @param width Width of pty in characters
		 * @param height Height of pty in characters
		 * @param width_px Width of pty in pixels
		 * @param height_px Height of pty in pixels
		 */
		[CCode (cname = "libssh2_channel_request_pty_ex")]
		public Error request_pty ([CCode (array_length_type = "unsigned int")] uint8[] term, [CCode (array_length_type = "unsigned int")] uint8[]? mode = null, int width = TERM_WIDTH, int height = TERM_HEIGHT, int width_px = TERM_WIDTH_PX, int height_px = TERM_HEIGHT_PX);
		[CCode (cname = "libssh2_channel_request_pty_size_ex")]
		public Error request_pty_size (int width, int height, int width_px = 0, int height_px = 0);
		[CCode (cname = "libssh2_channel_x11_req")]
		public Error request_x11 (int screen_number);
		[CCode (cname = "libssh2_channel_x11_req_ex")]
		public Error request_x11_ex (bool single_connection, string? auth_proto, string? auth_cookie, int screen_number);
		/**
		 * Tell the remote host that no further data will be sent on the specified channel.
		 *
		 * Processes typically interpret this as a closed stdin descriptor.
		 */
		[CCode (cname = "libssh2_channel_send_eof")]
		public Error send_eof ();
		/**
		 * Set an environment variable in the remote channel's process space.
		 * @see set_env_ex
		 */
		[CCode (cname = "libssh2_channel_setenv")]
		public Error set_env (string varname, string @value);
		/**
		 * Set an environment variable in the remote channel's process space.
		 *
		 * Note that this does not make sense for all channel types and may be ignored by the server despite returning success.
		 */
		[CCode (cname = "libssh2_channel_setenv_ex")]
		public Error set_env_ex ([CCode (array_length_type = "unsigned int")] uint8[] varname, [CCode (array_length_type = "unsigned int")] uint8[] @value);
		/**
		 * Set extended data handling mode
		 *
		 * Change how a channel deals with extended data packets.
		 *
		 * By default all extended data is queued until read by {@link read_stream}.
		 */
		[CCode (cname = "libssh2_channel_handle_extended_data2")]
		public Error set_handle_extended_data (ExtendedData mode);
		[CCode (cname = "libssh2_channel_exec")]
		public Error start_command (string command);
		/**
		 * Initiate a request on a session type channel such as returned by {@link Session.open}
		 * @param request Type of process to startup. The SSH2 protocol currently defines shell, exec, and subsystem as standard process services.
		 * @param message Request specific message data to include.
		 */
		[CCode (cname = "libssh2_channel_process_startup")]
		public Error start_process ([CCode (array_length_type = "unsigned int")] uint8[] request, [CCode (array_length_type = "unsigned int")] uint8[] message);
		[CCode (cname = "libssh2_channel_shell")]
		public Error start_shell ();
		[CCode (cname = "libssh2_channel_subsystem")]
		public Error start_subsystem (string subsystem);
		/**
		 * Check the status of the read window
		 *
		 * @return the number of bytes which the remote end may send without overflowing the window limit
		 * @param window_size_initial the window_size_initial as defined by the {@link Session.open} request
		 * @param read_avail the number of bytes actually available to be read
		 */
		[CCode (cname = "libssh2_channel_window_read_ex")]
		public ulong window_read (out ulong read_avail, out ulong window_size_initial);
		/**
		 * Check the status of the write window
		 *
		 * Check the status of the write window Returns the number of bytes which may be safely written on the channel without blocking.
		 * @param window_size_initial the size of the initial window as defined by the {@link Session.open} request
		 * @return number of bytes which may be safely writen on the channel without blocking.
		 */
		[CCode (cname = "libssh2_channel_window_write_ex")]
		public ulong window_write (out ulong window_size_initial = null);
		/**
		 * Write data to the default channel
		 * @see write_ex
		 */
		[CCode (cname = "libssh2_channel_write")]
		public ssize_t write ([CCode (array_length_type = "size_t")] uint8[] buf);
		/**
		 * Write data to a channel stream blocking
		 *
		 * Write data to a channel stream. All channel streams have one standard I/O substream (0), and may have up to 2^32 extended data streams. The SSH2 protocol currently defines a stream ID of 1 to be the stderr substream.
		 *
		 * As much as possible of the buffer and put it into a single SSH protocol packet. This means that to get maximum performance when sending larger files, you should try to always pass in at least 32K of data to this function.
		 * @param stream_id substream ID number (e.g. 0 or SSH_EXTENDED_DATA_STDERR)
		 * @param buf buffer to write
		 * @return Actual number of bytes written or negative on failure.
		 */
		public ssize_t write_ex (int stream_id, [CCode (array_length_type = "size_t")] uint8[] buf);
		/**
		 * Write data to the stderr channel
		 * @see write_ex
		 */
		[CCode (cname = "libssh2_channel_write_stderr")]
		public ssize_t write_stderr ([CCode (array_length_type = "size_t")] uint8[] buf);
		/**
		 * Wait for the remote to close the channel
		 *
		 * Enter a temporary blocking state until the remote host closes the named channel. Typically sent after {@link close} in order to examine the exit status.
		 */
		[CCode (cname = "libssh2_channel_wait_closed")]
		public Error wait_closed ();
		/**
		 * Wait for the remote end to acknowledge an EOF request.
		 */
		[CCode (cname = "libssh2_channel_wait_eof")]
		public Error wait_eof ();
	}
	[CCode (cname = "struct libssh2_knownhost", has_type_id = false)]
	[Compact]
	public class Host {
		/**
		 * The host's name
		 *
		 * If null, no plain text host name exists.
		 */
		public string? name;
		/**
		 * Key in base64/printable format
		 */
		public string key;
		public HostFormat typemask;
		/**
		 * Remove a host from the collection of known hosts.
		 */
		[CCode (cname = "libssh2_knownhost_del", instance_pos = -1)]
		[DestroysInstance]
		public void remove_from (KnownHosts hosts);
	}
	/**
	 * A collection of known hosts.
	 */
	[CCode (cname = "LIBSSH2_KNOWNHOSTS", free_function = "libssh2_knownhost_free", has_type_id = false)]
	[Compact]
	public class KnownHosts {
		[CCode (cname = "int", cprefix = "LIBSSH2_KNOWNHOST_FILE_", has_type_id = false)]
		public enum FileType {
			OPENSSH
		}
		/**
		 * Add a host and its associated key to the collection of known hosts.
		 *
		 * If SHA1 is selected as type, the salt must be provided to the salt
		 * argument. This too base64 encoded.
		 *
		 * The SHA-1 hash is what OpenSSH can be told to use in known_hosts files. If
		 * a custom type is used, salt is ignored and you must provide the host
		 * pre-hashed when checking for it in the {@link check} function.
		 * @param type specifies on what format the given host and keys are
		 */
		[CCode (cname = "libssh2_knownhost_add")]
		//  [Deprecated (replacement = "addc")]
		public Error add (string host, string? salt, [CCode (array_length_type = "size_t")] uint8[] key, HostFormat type, out unowned Host? result);
		/**
		 * Add a host and its associated key to the collection of known hosts with a comment.
		 *
		 * @param comment a comment argument that may be null. A null comment
		 * indicates there is no comment and the entry will end directly after the
		 * key when written out to a file. An empty string "" comment will
		 * indicate an empty comment which will cause a single space to be written
		 * after the key.
		 * @see add
		 */
		[CCode (cname = "libssh2_knownhost_addc")]
		public Error addc (string host, string? salt, [CCode (array_length_type = "size_t")] uint8[] key, [CCode (array_length_type = "size_t")] uint8[]? comment, HostFormat type, out unowned Host? result);
		/**
		 * Check a host and its associated key against the collection of known hosts.
		 *
		 * The type is the type/format of the given host name.
		 */
		[CCode (cname = "libssh2_knownhost_check")]
		public CheckResult check (string host, [CCode (array_length_type = "size_t")] uint8[] key, HostFormat typemask, out unowned Host? knownhost);
		/**
		 * Check a host and port.
		 * @see check
		 */
		[CCode (cname = "libssh2_knownhost_checkp")]
		public CheckResult checkp (string host, int port, [CCode (array_length_type = "size_t")] uint8[] key, HostFormat typemask, out unowned Host? knownhost);
		/**
		 * Traverse the internal list of known hosts.
		 *
		 * @param prev Pass null to get the first one or pass a poiner to the
		 * previously returned one to get the next.
		 * @return 0 if a fine host was returned, 1 if end of hosts, negative on errors
		 */
		[CCode (cname = "libssh2_knownhost_get")]
		public int next (out unowned Host? result, Host? prev);
		/**
		 * Add hosts+key pairs from a given file.
		 *
		 * @return a negative value for error or number of successfully added hosts.
		 */
		[CCode (cname = "libssh2_knownhost_readfile")]
		public int read_file (string filename, FileType type = FileType.OPENSSH);
		/**
		 * Process a line from a known hosts file.
		 */
		[CCode (cname = "libssh2_knownhost_readline")]
		public Error read_line ([CCode (array_length_type = "size_t")] uint8[] line, FileType type = FileType.OPENSSH);
		/**
		 * Write hosts+key pairs to a given file.
		 */
		[CCode (cname = "libssh2_knownhost_writefile")]
		public Error write_file (string filename, FileType type = FileType.OPENSSH);
		/**
		 * Ask libssh2 to convert a known host to an output line for storage.
		 */
		[CCode (cname = "libssh2_knownhost_writeline")]
		public Error write_line (Host known, [CCode (array_length_type = "size_t")] uint8[] buffer, out size_t len, FileType type = FileType.OPENSSH);
	}
	[CCode (cname = "LIBSSH2_LISTENER", free_function = "libssh2_channel_forward_cancel", has_type_id = false)]
	[Compact]
	public class Listener {
		/**
		 * Accept a queued connection
		 */
		[CCode (cname = "libssh2_channel_forward_accept")]
		public Channel? accept ();
	}
	[CCode (cname = "LIBSSH2_PUBLICKEY", free_function = "libssh2_publickey_shutdown", has_type_id = false, cheader_filename = "libssh2_publickey.h")]
	[Compact]
	public class PublicKey {
		/**
		 * Add a new public key entry.
		 * @see add_ex
		 */
		[CCode (cname = "libssh2_publickey_ad")]
		public Error add (string name, [CCode (array_length_type = "unsigned long")] uint8[] blob, bool overwrite, [CCode (array_length_pos = 3.1)] key_attribute[]? attrs);
		/**
		 * Add a new public key entry.
		 */
		[CCode (cname = "libssh2_publickey_add_ex")]
		public Error add_ex ([CCode (array_length_type = "unsigned long")] uint8[] name, [CCode (array_length_type = "unsigned long")] uint8[] blob, bool overwrite, [CCode (array_length_pos = 3.1)] key_attribute[]? attrs);
		[CCode (cname = "libssh2_publickey_list_free")]
		public void list_free ([CCode (array_length = false)] owned key_list[] pkey_list);
		/**
		 * Fetch a list of supported public key from a server
		 *
		 * You must free the resulting list using {@link list_free}.
		 */
		[CCode (cname = "libssh2_publickey_list_fetch")]
		public Error list_public_keys ([CCode (array_length_pos = 0.1, array_length_type = "unsigned long")] out key_list[] pkey_list);
		[CCode (cname = "libssh2_publickey_remove")]
		public Error remove ([CCode (array_length_type = "unsigned long")] uint8[] name, [CCode (array_length_type = "unsigned long")] uint8[] blob);
		[CCode (cname = "libssh2_publickey_remove_ex")]
		public Error remove_ex ([CCode (array_length_type = "unsigned long")] uint8[] name, [CCode (array_length_type = "unsigned long")] uint8[] blob);
	}
	[CCode (cname = "LIBSSH2_SESSION", free_function = "libssh2_session_free")]
	[Compact]
	public class Session<T> {
		[CCode (cname = "libssh2_session_init_ex", simple_generics = true)]
		private static Session<T> _create<T> (void* alloc, void* free, void* realloc, void* user_data);
		public static Session<T> create<T> (T user_data = null) {
			return _create<T>((void*) GLib.try_malloc, (void*) GLib.free, (void*) GLib.try_realloc, user_data);
		}
		public bool authenticated {
			[CCode (cname = "libssh2_userauth_authenticated")]
			get;
		}
		/**
		 * The banner that will be sent to the remote host when the SSH session is started.
		 *
		 * This is optional; a banner corresponding to the protocol and libssh2 version will be sent by default.
		 */
		public string banner {
			[CCode (cname = "libssh2_session_banner_set")]
			set;
			[CCode (cname = "libssh2_session_banner_get")]
			get;
		}
		/**
		 * The directions that socket should wait for before calling libssh2 function again
		 */
		public Direction block_directions {
			[CCode (cname = "libssh2_session_block_directions")]
			get;
		}
		public bool blocking {
			[CCode (cname = "libssh2_session_set_blocking")]
			set;
			[CCode (cname = "libssh2_session_get_blocking")]
			get;
		}
		public Error last_error {
			[CCode (cname = "libssh2_session_last_errno")]
			get;
		}
		public long timeout {
			[CCode (cname = "libssh2_session_set_timeout")]
			set;
			[CCode (cname = "libssh2_session_get_timeout")]
			get;
		}
		public unowned T userdata {
			get {
				return *access_abstract ();
			}
			set {
				*access_abstract () = value;
			}
		}
		[CCode (cname = "libssh2_hostkey_hash", array_length = false)]
		private unowned uint8[] _get_hostkey_hash (HashType type);
		[CCode (cname = "libssh2_session_callback_set", simple_generics = true)]
		private S _set_callback<S> (CallbackType cbtype, S callback);
		/**
		 * Return a pointer to where the abstract pointer provided is stored.
		 *
		 * By providing a doubly de-referenced pointer, the internal storage of the session instance may be modified in place.
		 * @see userdata
		 */
		[CCode (cname = "libssh2_session_abstract", simple_generics = true)]
		public T * access_abstract ();
		/**
		 * Authenticate a session with username and password
		 * @see auth_password_ex
		 */
		[CCode (cname = "libssh2_userauth_password")]
		public Error auth_password (string username, string password);
		/**
		 * Authenticate a session with username and password
		 *
		 * Attempt basic password authentication. Note that many SSH servers which appear to support ordinary password authentication actually have it disabled and use Keyboard Interactive authentication (routed via PAM or another authentication backed) instead.
		 * @param username Name of user to attempt plain password authentication for.
		 * @param password Password to use for authenticating username.
		 * @param passwd_change_cb If the host accepts authentication but requests that the password be changed, this callback will be issued. If no callback is defined, but server required password change, authentication will fail.
		 */
		[CCode (cname = "libssh2_userauth_password_ex")]
		public Error auth_password_ex ([CCode (array_length_type = "unsigned int")] uint8[] username, [CCode (array_length_type = "unsigned int")] uint8[] password, ChangePasswdHandler<T>? passwd_change_cb = null);
		/**
		 * Authenticate using a callback function
		 */
		[CCode (cname = "libssh2_userauth_publickey")]
		public Error auth_publickey (string username, [CCode (array_length_type = "size_t")] uint8[] pubkeydata, PublicKeySignFunc<T> sign_func);
		/**
		 * Authenticate a session with a public key, read from a file
		 * @see auth_publickey_from_file_ex
		 */
		[CCode (cname = "libssh2_userauth_publickey_fromfile")]
		public Error auth_publickey_from_file (string username, string publickey, string privatekey, string? passphrase);
		/**
		 * Authenticate a session with a public key, read from a file
		 *
		 * Attempt public key authentication using a PEM encoded private key file stored on disk
		 * @param username Remote user name to authenticate as.
		 * @param publickey Path and name of public key file. (e.g., /etc/ssh/hostkey.pub)
		 * @param privatekey Path and name of private key file. (e.g., /etc/ssh/hostkey)
		 * @param passphrase Passphrase to use when decoding private key file.
		 */
		[CCode (cname = "libssh2_userauth_publickey_fromfile_ex")]
		public Error auth_publickey_from_file_ex ([CCode (array_length_type = "unsigned int")] uint8[] username, string publickey, string privatekey, string? passphrase);
		[CCode (cname = "libssh2_userauth_hostbased_fromfile")]
		public Error auth_host_based_from_file (string username, string publickey, string privatekey, string? passphrase, string hostname, string local_user_name);
		[CCode (cname = "libssh2_userauth_hostbased_fromfile_ex")]
		public Error auth_host_based_from_file_ex ([CCode (array_length_type = "unsigned int")] uint8[] username, string publickey, string privatekey, string? passphrase, [CCode (array_length_type = "unsigned int")] uint8[] hostname, [CCode (array_length_type = "unsigned int")] uint8[] local_user_name);
		/**
		 * Authenticate a session using a challenge-response authentication
		 * @see auth_keyboard_interactive_ex
		 */
		[CCode (cname = "libssh2_userauth_keyboard_interactive")]
		public Error auth_keyboard_interactive (string username, KeyboardInteractiveHandler<T> reponse_callback);
		/**
		 * Authenticate a session using a challenge-response authentication
		 *
		 * Note that many SSH servers will always issue single "password" challenge, requesting actual password as response, but it is not required by the protocol, and various authentication schemes, such as smartcard authentication may use keyboard-interactive authentication type too.
		 * @param username Name of user to attempt plain password authentication for.
		 * @param response_callback As authentication proceeds, host issues several (1 or more) challenges and requires responses. This callback will be called at this moment. Callback is responsible to obtain responses for the challenges, fill the provided data structure and then return control. Responses will be sent to the host.
		 */
		[CCode (cname = "libssh2_userauth_keyboard_interactive_ex")]
		public Error auth_keyboard_interactive_ex ([CCode (array_length_type = "unsigned int")] uint8[] username, KeyboardInteractiveHandler<T> response_callback);
		[CCode (cname = "libssh2_agent_init")]
		public Agent? create_agent ();
		/**
		 * Tunnel a TCP/IP connection through the SSH transport via the remote host to a third party.
		 *
		 * Communication from the client to the SSH server remains encrypted, communication from the server to the 3rd party host travels in cleartext.
		 * @param host Third party host to connect to using the SSH host as a proxy.
		 * @param port Port on third party host to connect to.
		 * @param shost Host to tell the SSH server the connection originated on.
		 * @param sport Port to tell the SSH server the connection originated from.
		 */
		[CCode (cname = "libssh2_channel_direct_tcpip_ex")]
		public Channel? direct_tcpip (string host, int port, string shost = "127.0.0.1", int sport = 22);
		/**
		 * Disconnect by application.
		 * @see disconnect_ex
		 */
		[CCode (cname = "libssh2_session_disconnect")]
		public Error disconnect (string description);
		/**
		 * Send a disconnect message to the remote host associated with session, along with a reason symbol and a verbose description.
		 *
		 * @param description Human readable reason for disconnection.
		 * @param lang Localization string describing the langauge/encoding of the description provided.
		 */
		[CCode (cname = "libssh2_session_disconnect_ex")]
		public Error disconnect_ex (Disconnect reason, string description, string lang);
		/**
		 * Instruct the remote SSH server to begin listening for inbound TCP/IP connections.
		 * @see forward_listen_ex
		 */
		[CCode (cname = "libssh2_channel_forward_listen")]
		public Listener? forward_listen (int port);
		/**
		 * Instruct the remote SSH server to begin listening for inbound TCP/IP connections.
		 *
		 * New connections will be queued by the library until accepted.
		 * @param host specific address to bind to on the remote host. Binding to 0.0.0.0 (default when null) will bind to all available addresses.
		 * @param port port to bind to on the remote host. When 0 is passed, the remote host will select the first available dynamic port.
		 * @param bound_port Populated with the actual port bound on the remote host. Useful when requesting dynamic port numbers.
		 * @param queue_maxsize Maximum number of pending connections to queue before rejecting further attempts.
		 */
		[CCode (cname = "libssh2_channel_forward_listen_ex")]
		public Listener? forward_listen_ex (string? host, int port, out int bound_port, int queue_maxsize = 16);
		[CCode (cname = "libssh2_knownhost_init")]
		public KnownHosts? get_known_hosts ();
		/**
		 * Determine the most recent error condition and its cause.
		 */
		[CCode (cname = "libssh2_session_last_error")]
		public Error get_last_error (out char[] errmsg, bool want_buf = true);
		/**
		 * Returns the computed digest of the remote system's hostkey. The length of the returned string is hash-type specific (e.g., 16 bytes for MD5, 20 bytes for SHA1).
		 */
		public unowned uint8[]? get_host_key_hash (HashType type) {
			unowned uint8[]? hash = _get_hostkey_hash (type);
			if (hash == null) {
				return null;
			}
			switch (type) {
			 case HashType.SHA1 :
				 hash.length = 20;
				 break;

			 case HashType.MD5 :
				 hash.length = 16;
				 break;
			}
			return hash;
		}
		[CCode (cname = "libssh2_session_hostkey", array_length_type = "size_t", array_length_pos = 0.1)]
		public unowned uint8[] get_host_key (out KeyType type);
		/**
		 * Returns the actual method negotiated for a particular transport parameter.
		 * @return Negotiated method or null if the session has not yet been started.
		 */
		[CCode (cname = "libssh2_session_methods")]
		public unowned string get_methods (MethodType method_type);
		[CCode (cname = "libssh2_publickey_init")]
		public PublicKey? get_public_key ();
		[CCode (cname = "libssh2_sftp_init")]
		public SFTP? get_sftp ();
		[CCode (cname = "libssh2_session_supported_algs")]
		private int _supported_algs (MethodType method_type, out string[]? algs);
		public Error get_supported_algs (MethodType method_type, out string[]? algs) {
			var result = _supported_algs (method_type, out algs);
			if (result < 1) {
				return (Error) result;
			} else {
				((!)algs).length = result;
				return Error.NONE;
			}
		}

		[CCode (cname = "libssh2_session_handshake")]
		public Error handshake (int sock);
		/**
		 * List supported authentication methods
		 *
		 * Send a SSH_USERAUTH_NONE request to the remote host. Unless the remote host is configured to accept none as a viable authentication scheme (unlikely), it will return SSH_USERAUTH_FAILURE along with a listing of what authentication schemes it does support. In the unlikely event that none authentication succeeds, this method with return null. This case may be distinguished from a failing case by examining {@link authenticated}
		 * @param username Username which will be used while authenticating. Note that most server implementations do not permit attempting authentication with different usernames between requests. Therefore this must be the same username you will use on later userauth calls.
		 * @return On success a comma delimited list of supported authentication schemes.
		 */
		[CCode (cname = "libssh2_userauth_list")]
		public unowned string list_authentication ([CCode (array_length_type = "unsigned int")] uint8[] username);
		/**
		 * Establish a generic session channel
		 * @param channel_type Channel type to open. Typically one of session, directtcpip, or tcpipforward. The SSH2 protocol allowed for additional types including local, custom channel types.
		 * @param window_size Maximum amount of unacknowledged data remote host is allowed to send before receiving an SSH_MSG_CHANNEL_WINDOW_ADJUST packet.
		 * @param packet_size Maximum number of bytes remote host is allowed to send in a single SSH_MSG_CHANNEL_DATA or SSG_MSG_CHANNEL_EXTENDED_DATA packet.
		 * @param message Additional data as required by the selected channel_type.
		 * @see open_session
		 * @see direct_tcpip
		 * @see forward_listen
		 */
		[CCode (cname = "libssh2_channel_open_ex")]
		public Channel? open ([CCode (array_length_type = "unsigned int")] uint8[] channel_type, uint window_size = Channel.WINDOW_DEFAULT, uint packet_size = Channel.PACKET_DEFAULT, [CCode (array_length_type = "unsigned int")] uint8[]? message = null);
		[CCode (cname = "libssh2_channel_open_session")]
		public Channel? open_session ();
		[CCode (cname = "libssh2_scp_recv")]
		public Channel? scp_recv (string path, out Posix.Stat sb);
		[CCode (cname = "libssh2_scp_send64")]
		public Channel? scp_send (string path, Posix.mode_t mode, int64 size, time_t mtime, time_t atime);
		/**
		 * Send a keepalive message if needed.
		 *
		 * @param seconds_to_next indicates how many seconds you can sleep after
		 * this call before you need to call it again.
		 */
		[CCode (cname = "libssh2_keepalive_send")]
		public Error send_keep_alive (out int seconds_to_next);
		/**
		 * Set a handler when a SSH_MSG_DEBUG message is received
		 * @param callback the handler, or null to ignore this message
		 * @return the previous callback handler, if there was one.
		 */
		public DebugHandler<T>? set_debug_handler (DebugHandler<T>? callback) {
			return _set_callback<DebugHandler<T>? > (CallbackType.DEBUG, callback);
		}
		/**
		 * Set a handler when a SSH_MSG_DISCONNECT message is received
		 * @param callback the handler, or null to ignore this message
		 * @return the previous callback handler, if there was one.
		 */
		public DisconnectHandler<T>? set_disconnect_handler (DisconnectHandler<T>? callback) {
			return _set_callback<DisconnectHandler<T>? > (CallbackType.DISCONNECT, callback);
		}
		[CCode (cname = "libssh2_session_flag")]
		public Error set_flag (Option option, bool @value);
		/**
		 * Set a handler when a SSH_MSG_IGNORE message is received
		 * @param callback the handler, or null to ignore this message
		 * @return the previous callback handler, if there was one.
		 */
		public IgnoreHandler<T>? set_ignore_handler (IgnoreHandler<T>? callback) {
			return _set_callback<IgnoreHandler<T>? > (CallbackType.IGNORE, callback);
		}
		/**
		 * Set how often keepalive messages should be sent.
		 *
		 * Note that non-blocking applications are responsible for sending the
		 * keep-alive messages using {@link send_keep_alive}.
		 *
		 * @param want_reply indicates whether the keepalive messages should
		 * request a response from the server.
		 * @param interval is number of seconds that can pass without any I/O, use
		 * 0 (the default) to disable keepalives. To avoid some busy-loop
		 * corner-cases, if you specify an interval of 1 it will be treated as 2.
		 */
		[CCode (cname = "libssh2_keepalive_config")]
		public void set_keep_alive (bool want_reply, uint interval);
		/**
		 * Set a handler when a mismatched MAC has been detected in the transport layer.
		 * @param callback the handler, or null to ignore this message
		 * @return the previous callback handler, if there was one.
		 */
		public MACErrorHandler<T>? set_mac_error_handler (MACErrorHandler<T>? callback) {
			return _set_callback<MACErrorHandler<T>? > (CallbackType.MACERROR, callback);
		}
		public SendHandler<T>? set_send_handler (SendHandler<T>? callback) {
			return _set_callback<SendHandler<T>? > (CallbackType.SEND, callback);
		}
		public RecvHandler<T>? set_recv_handler (RecvHandler<T>? callback) {
			return _set_callback<RecvHandler<T>? > (CallbackType.RECV, callback);
		}
		/**
		 * Set preferred methods to be negotiated. These preferrences must be set prior to calling {@link handshake} as they are used during the protocol initiation phase.
		 * @param prefs Comma-delimited list of preferred methods to use with the most preferred listed first and the least preferred listed last. If a method is listed which is not supported by libssh2 it will be ignored and not sent to the remote host during protocol negotiation.
		 */
		[CCode (cname = "libssh2_session_method_pref")]
		public Error set_method_pref (MethodType method, string prefs);
		/**
		 * Enables tracing.
		 *
		 * This has no function in builds that aren't built with debug enabled
		 */
		[CCode (cname = "libssh2_trace")]
		public Error set_trace (Trace trace);
		[CCode (cname = "libssh2_trace_sethandler", simple_generics = true)]
		public Error set_trace_handler ([CCode (target_pos = 0.1)] TraceFunc<T> handler);
		/**
		 * Set a handler when an X11 connection has been accepted
		 * @param callback the handler, or null to ignore this message
		 * @return the previous callback handler, if there was one.
		 */
		public X11Handler<T>? set_x_handler (X11Handler<T>? callback) {
			return _set_callback<X11Handler<T>? > (CallbackType.X11, callback);
		}
		[CCode (cname = "int", cprefix = "LIBSSH2_CALLBACK_")]
		private enum CallbackType {
			IGNORE,
			DEBUG,
			DISCONNECT,
			MACERROR,
			X11,
			SEND,
			RECV
		}
		[CCode (cname = "libssh2_passwd_changereq_delegate", simple_generics = true, has_target = false)]
		public delegate void ChangePasswdHandler<T> (Session<T> session, out uint8[]? newpw, ref T user_data);
		[CCode (cname = "libssh2_debug_delegate", simple_generics = true, has_target = false)]
		public delegate void DebugHandler<T> (Session<T> session, bool always_display, uint8[] message, uint8[] language, ref T user_data);
		[CCode (cname = "libssh2_disconnect_delegate", simple_generics = true, has_target = false)]
		public delegate void DisconnectHandler<T> (Session<T> session, Disconnect reason, uint8[] message, uint8[] language, ref T user_data);
		[CCode (cname = "libssh2_ignore_delegate", simple_generics = true, has_target = false)]
		public delegate void IgnoreHandler<T> (Session<T> session, uint8[] message, ref T user_data);
		[CCode (cname = "libssh2_userauth_publickey_sign_delegate", simple_generics = true)]
		public delegate Error PublicKeySignFunc<T> (Session<T> session, [CCode (array_length_type = "size_t")] out uint8[] sig, [CCode (array_length_type = "size_t")] uint8[] data);
		[CCode (cname = "libssh2_userauth_kbdint_response_delegate", simple_generics = true, has_target = false)]
		public delegate void KeyboardInteractiveHandler<T> ([CCode (array_length_type = "int")] uint8[] name, [CCode (array_length_type = "int")] uint8[] instruction, [CCode (array_length_pos = 2.1)] keyboard_prompt prompts, [CCode (array_length = false)] keyboard_response responses, ref T user_data);
		[CCode (cname = "libssh2_recv_func_delegate", simple_generics = true, has_target = false)]
		public delegate ssize_t RecvHandler<T> (int socket, [CCode (array_length_type = "size_t")] uint8[] buffer, int flags, ref T user_data);
		[CCode (cname = "libssh2_send_func_delegate", simple_generics = true, has_target = false)]
		public delegate ssize_t SendHandler<T> (int socket, [CCode (array_length_type = "size_t")] uint8[] buffer, int flags, ref T user_data);

		/**
		 * Handler for mismatched MAC packets in transport layer.
		 * @return true to discard. If false, the packet will be accepted nonetheless.
		 */
		[CCode (cname = "libssh2_macerror_delegate", simple_generics = true, has_target = false)]
		public delegate bool MACErrorHandler<T> (Session<T> session, uint8[] packet, ref T user_data);
		[CCode (cname = "libssh2_x11_open_delegate", simple_generics = true, has_target = false)]
		public delegate void X11Handler<T> (Session<T> session, Channel channel, string host, int port, ref T user_data);
	}
	[CCode (cname = "LIBSSH2_SFTP", free_function = "libssh2_sftp_shutdown", cheader_filename = "libssh2_sftp.h")]
	[Compact]
	public class SFTP {
		[CCode (cname = "LIBSSH2_SFTP_PACKET_MAXLEN", cheader_filename = "libssh2_sftp.h")]
		public const int PACKET_MAXLEN;
		/**
		 * The last error code produced by the SFTP layer.
		 *
		 * Note that this only returns a sensible error code if libssh2 returned
		 * {@link Error.SFTP_PROTOCOL} in a previous call.
		 */
		public SftpError last_error {
			[CCode (cname = "libssh2_sftp_last_error")]
			get;
		}
		/**
		 * Get status of a link
		 */
		[CCode (cname = "libssh2_sftp_lstat")]
		public Error lstat (string path, out sftp_attributes attrs);
		/**
		 * Create a directory on the remote file system
		 * @param path full path of the new directory to create. Note that the new directory's parents must all exist priot to making this call.
		 * @param mode directory creation mode (e.g. 0755).
		 */
		[CCode (cname = "libssh2_sftp_mkdir_ex")]
		public Error mkdir (string path, long mode);
		/**
		 * Open filehandle for a file on SFTP.
		 */
		[CCode (cname = "libssh2_sftp_open")]
		public SftpHandle? open (string filename, Transfer flags, Posix.mode_t mode);
		/**
		 * Open filehandle for a directory on SFTP.
		 */
		[CCode (cname = "libssh2_sftp_opendir")]
		public SftpHandle? open_dir (string path);
		/**
		 * Resolve a symbolic link filesystem object to its next target.
		 *
		 * @return the number of bytes it copied to the target buffer (not including the terminating zero) or negative on failure.
		 * @see Error
		 */
		[CCode (cname = "libssh2_sftp_readlink")]
		public int read_link (string path, [CCode (array_length_type = "unsigned int")] uint8[] target);
		/**
		 * Resolve a complex, relative, or symlinked filepath to its effective target.
		 *
		 * @return the number of bytes it copied to the target buffer (not including the terminating zero) or negative on failure.
		 * @see Error
		 */
		[CCode (cname = "libssh2_sftp_realpath")]
		public int real_path (string path, [CCode (array_length_type = "unsigned int")] uint8[] target);
		/**
		 * Rename a filesystem object on the remote filesystem.
		 *
		 * Use expected flags.
		 * @see rename_ex
		 */
		[CCode (cname = "libssh2_sftp_rename")]
		public Error rename (string source_file, string dest_file);
		/**
		 * Rename a filesystem object on the remote filesystem.
		 *
		 * The semantics of this command typically include the ability to move a
		 * filsystem object between folders and/or filesystem mounts. If the
		 * {@link Rename.OVERWRITE} flag is not set and the destfile entry already
		 * exists, the operation will fail. Use of the other two flags indicate
		 * a preference (but not a requirement) for the remote end to perform an
		 * atomic rename operation and/or using native system calls when possible.
		 */
		[CCode (cname = "libssh2_sftp_rename_ex")]
		public Error rename_ex ([CCode (array_length_type = "unsigned int")] uint8[] source_filename, [CCode (array_length_type = "unsigned int")] uint8[] dest_filename, Rename flags);
		/**
		 * Remove a directory from the remote file system.
		 */
		[CCode (cname = "libssh2_sftp_rmdir")]
		public Error rmdir (string path);
		/**
		 * Set status of a file
		 */
		[CCode (cname = "libssh2_sftp_setstat")]
		public Error set_stat (string path, sftp_attributes attrs);
		/**
		 * Get status of a file
		 */
		[CCode (cname = "libssh2_sftp_stat")]
		public Error stat (string path, out sftp_attributes attrs);
		/**
		 * Get file system statistics
		 */
		[CCode (cname = "libssh2_sftp_statvfs")]
		public Error stat_vfs ([CCode (array_length_type = "size_t")] uint8[] path, out stat_vfs st);
		/**
		 * Create a symbolic link between two filesystem objects.
		 */
		[CCode (cname = "libssh2_sftp_symlink")]
		public Error symlink (string orig, string linkpath);
		/**
		 * Unlink (delete) an SFTP file
		 * @see unlink_ex
		 */
		[CCode (cname = "libssh2_sftp_unlink")]
		public Error unlink (string filename);
		/**
		 * Unlink (delete) an SFTP file
		 */
		[CCode (cname = "libssh2_sftp_unlink_ex")]
		public Error unlink_ex ([CCode (array_length_type = "unsigned int")] uint8[] source_filename);
	}
	[CCode (cname = "LIBSSH2_SFTP_HANDLE", free_function = "libssh2_sftp_close_handle", cheader_filename = "libssh2_sftp.h")]
	[Compact]
	public class SftpHandle {
		/**
		 * Reads a block of data.
		 *
		 * This method is modelled after the POSIX read(2) function and uses the
		 * same calling semantics. It will attempt to read as much as possible
		 * however it may not fill all of buffer if the file pointer reaches the
		 * end or if further reads would cause the socket to block.
		 * @return Number of bytes actually populated into buffer, or negative on
		 * failure. It returns {@link Error.AGAIN} when
		 * it would otherwise block.s
		 */
		[CCode (cname = "libssh2_sftp_read")]
		public ssize_t read ([CCode (array_length_size = "size_t")] uint8[] buffer);
		/**
		 * Reads a block of data and returns file entry information for the
		 * next entry, if any.
		 * @param buffer a buffer to read data into.
		 * @param longentry a buffer to read data into. The format of the is unspecified by SFTP protocol. It MUST be suitable for use in the output of a directory listing command (in fact, the recommended operation for a directory listing command is to simply display this data).
		 * @return number of bytes actually populated into buffer (not counting the terminating zero), or negative on failure. It returns {@link Error.AGAIN} when it would otherwise block.
		 */
		[CCode (cname = "libssh2_sftp_readdir_ex")]
		public int read_dir ([CCode (array_length_size = "size_t")] uint8[] buffer, [CCode (array_length_size = "size_t")] uint8[]? longentry, sftp_attributes attrs);
		[CCode (cname = "libssh2_sftp_rewind")]
		public void rewind ();
		/**
		 * Set the read/write position indicator within a file
		 *
		 * Move the file handle's internal pointer to an arbitrary location. Note
		 * that libssh2 implements file pointers as a localized concept to make
		 * file access appear more POSIX like. No packets are exchanged with the
		 * server during a seek operation. The localized file pointer is simply
		 * used as a convenience offset during read/write operations.
		 */
		[CCode (cname = "libssh2_sftp_seek64")]
		public void seek (uint64 offset);
		/**
		 * Set attributes on an SFTP file handle
		 */
		[CCode (cname = "libssh2_sftp_fsetstat")]
		public Error set_stat (sftp_attributes attrs);
		/**
		 * Get attributes on an SFTP file handle
		 */
		[CCode (cname = "libssh2_sftp_fstat")]
		public Error stat (out sftp_attributes attrs);
		/**
		 * Get file system statistics
		 */
		[CCode (cname = "libssh2_sftp_fstatvfs")]
		public Error stat_vfs (out stat_vfs st);
		/**
		 * Get the current read/write position indicator for a file
		 */
		[CCode (cname = "libssh2_sftp_tell64")]
		public uint64 tell ();
		/**
		 * Writes a block of data to the SFTP server.
		 *
		 * This method is modeled after the POSIX write() function and uses the same calling semantics.
		 *
		 * As much as possible of the buffer and put it into a single SFTP
		 * protocol packet. This means that to get maximum performance when sending
		 * larger files, you should try to always pass in at least 32K of data to
		 * this function.
		 *
		 * Starting in libssh2 version 1.2.8, the default behavior of libssh2 is to
		 * create several smaller outgoing pack‐ ets for all data you pass to this
		 * function and it will return a positive number as soon as the first
		 * packet is acknowledged from the server.
		 *
		 * This has the effect that sometimes more data has been sent off but isn't
		 * acked yet when this function returns, and when this function is
		 * subsequently called again to write more data, libssh2 will immediately
		 * figure out that the data is already received remotely.
		 *
		 * In most normal situation this should not cause any problems, but it
		 * should be noted that if you've once called this method with data and it
		 * returns short, you MUST still assume that the rest of the data might've
		 * been cached so you need to make sure you don't alter that data and
		 * think that the version you have in your next function invoke will be
		 * detected or used.
		 *
		 * The reason for this funny behavior is that SFTP can only send 32K data
		 * in each packet and it gets all packets acked individually. This
		 * means we cannot use a simple serial approach if we want to reach high
		 * performance even on high latency connections. And we want that.
		 *
		 * @return Actual number of bytes written or negative on failure. If this
		 * function returns 0 (zero) it should not be considered an error, but
		 * simply that there was no error but yet no payload data got sent to the
		 * other end.
		 */
		[CCode (cname = "libssh2_sftp_write")]
		public ssize_t write ([CCode (array_length_size = "size_t")] uint8[] buffer);
	}
	[CCode (cname = "libssh2_publickey_attribute", has_type_id = false, cheader_filename = "libssh2_publickey.h")]
	public struct key_attribute {
		[CCode (cname = "libssh2_publickey_attribute")]
		public key_attribute (string name, string @value, bool mandatory);
		[CCode (array_length_cname = "name_len", array_length_type = "unsigned long")]
		unowned uint8[] name;
		[CCode (array_length_cname = "value_len", array_length_type = "unsigned long")]
		unowned uint8[] @value;
		bool mandatory;
	}
	[CCode (cname = "libssh2_publickey_list")]
	public struct key_list {
		[CCode (array_length_cname = "name_len", array_length_type = "unsigned long")]
		uint8[] name;
		[CCode (array_length_cname = "blob_len", array_length_type = "unsigned long")]
		uint8[] blob;
		[CCode (array_length_cname = "num_attrs", array_length_type = "unsigned long")]
		key_attribute[] attrs;
	}
	[CCode (cname = "LIBSSH2_USERAUTH_KBDINT_PROMPT")]
	public struct keyboard_prompt {
		[CCode (array_length_cname = "length")]
		public uint8[] text;
		public bool echo;
	}
	[CCode (cname = "LIBSSH2_USERAUTH_KBDINT_RESPONSE")]
	public struct keyboard_response {
		[CCode (array_length_type = "unsigned int", array_length_cname = "length")]
		public uint8[] text;
	}
	[CCode (cname = "LIBSSH2_SFTP_ATTRIBUTES", has_type_id = false, cheader_filename = "libssh2_sftp.h")]
	public struct sftp_attributes {
		/**
		 * If flags contains an attribute, then the value in this
		 * struct will be meaningful Otherwise it should be ignored
		 */
		Attribute flags;
		/**
		 * Size of file in bytes
		 */
		uint64 filesize;
		/*
		 * Numerical the user owner
		 */
		ulong uid;
		/*
		 * Numerical the group owner
		 */
		ulong gid;
		Posix.mode_t permissions;
		/**
		 * Access time of file
		 */
		ulong atime;
		/**
		 * Modification time of file
		 */
		ulong mtime;
	}
	[CCode (cname = "LIBSSH2_SFTP_STATVFS", has_type_id = false, cheader_filename = "libssh2_sftp.h")]
	public struct stat_vfs {
		/**
		 * File system block size
		 */
		[CCode (cname = "f_bsize")]
		uint64 block_size;
		/**
		 * Fragment size
		 */
		[CCode (cname = "f_frsize")]
		uint64 frg_size;
		/**
		 * Size of the file system in frg_size units
		 */
		[CCode (cname = "f_blocks")]
		uint64 blocks;
		/**
		 * Number of free blocks
		 */
		[CCode (cname = "f_bfree")]
		uint64 blocks_free;
		/**
		 * Number of free blocks for non-root
		 */
		[CCode (cname = "f_bavail")]
		uint64 blocks_avail;
		/**
		 * Number of inodes
		 */
		[CCode (cname = "f_files")]
		uint64 files;
		/**
		 * Number of free inodes
		 */
		[CCode (cname = "f_ffree")]
		uint64 inodes_free;
		/**
		 * Number of free inodes for non-root
		 */
		[CCode (cname = "f_favail")]
		uint64 inodes_avail;
		/**
		 * File system ID
		 */
		[CCode (cname = "f_fsid")]
		uint64 fs_id;
		/**
		 * Mount flags
		 */
		[CCode (cname = "f_flag")]
		MountFlags flags;
		/**
		 * Maximum filename length
		 */
		[CCode (cname = "f_namemax")]
		uint64 name_max;
	}
	[CCode (cname = "unsigned long", cprefix = "LIBSSH2_SFTP_ATTR_", cheader_filename = "libssh2_sftp.h")]
	public enum Attribute {
		SIZE,
		UIDGID,
		PERMISSIONS,
		ACMODTIME,
		EXTENDED
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_KNOWNHOST_CHECK_", has_type_id = false)]
	public enum CheckResult {
		MATCH,
		MISMATCH,
		NOTFOUND,
		FAILURE
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_SESSION_BLOCK_", has_type_id = false)]
	[Flags]
	public enum Direction {
		INBOUND,
		OUTBOUND;
		public GLib.IOCondition to_condition () {
			GLib.IOCondition result = 0;
			if (Direction.INBOUND in this) {
				result |= GLib.IOCondition.IN;
			}
			if (Direction.OUTBOUND in this) {
				result |= GLib.IOCondition.OUT;
			}
			return result;
		}
	}
	/**
	 * Disconnect codes defined by SSH protocol
	 */
	[CCode (cname = "int", cprefix = "SSH_DISCONNECT_", has_type_id = false)]
	public enum Disconnect {
		HOST_NOT_ALLOWED_TO_CONNECT,
		PROTOCOL_ERROR,
		KEY_EXCHANGE_FAILED,
		RESERVED,
		MAC_ERROR,
		COMPRESSION_ERROR,
		SERVICE_NOT_AVAILABLE,
		PROTOCOL_VERSION_NOT_SUPPORTED,
		HOST_KEY_NOT_VERIFIABLE,
		CONNECTION_LOST,
		BY_APPLICATION,
		TOO_MANY_CONNECTIONS,
		AUTH_CANCELLED_BY_USER,
		NO_MORE_AUTH_METHODS_AVAILABLE,
		ILLEGAL_USER_NAME
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_ERROR_", has_type_id = false)]
	public enum Error {
		NONE,
		SOCKET_NONE,
		BANNER_RECV,
		BANNER_SEND,
		INVALID_MAC,
		KEX_FAILURE,
		ALLOC,
		SOCKET_SEND,
		KEY_EXCHANGE_FAILURE,
		TIMEOUT,
		HOSTKEY_INIT,
		HOSTKEY_SIGN,
		DECRYPT,
		SOCKET_DISCONNECT,
		PROTO,
		PASSWORD_EXPIRED,
		FILE,
		METHOD_NONE,
		AUTHENTICATION_FAILED,
		PUBLICKEY_UNVERIFIED,
		CHANNEL_OUTOFORDER,
		CHANNEL_FAILURE,
		CHANNEL_REQUEST_DENIED,
		CHANNEL_UNKNOWN,
		CHANNEL_WINDOW_EXCEEDED,
		CHANNEL_PACKET_EXCEEDED,
		CHANNEL_CLOSED,
		CHANNEL_EOF_SENT,
		SCP_PROTOCOL,
		ZLIB,
		SOCKET_TIMEOUT,
		SFTP_PROTOCOL,
		REQUEST_DENIED,
		METHOD_NOT_SUPPORTED,
		INVAL,
		INVALID_POLL_TYPE,
		PUBLICKEY_PROTOCOL,
		[CCode (cname = "LIBSSH2_ERROR_EAGAIN")]
		AGAIN,
		BUFFER_TOO_SMALL,
		BAD_USE,
		COMPRESS,
		OUT_OF_BOUNDARY,
		AGENT_PROTOCOL,
		SOCKET_RECV,
		ENCRYPT,
		BAD_SOCKET,
		KNOWN_HOSTS
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_CHANNEL_EXTENDED_DATA_", has_type_id = false)]
	public enum ExtendedData {
		/**
		 * Queue extended data for eventual reading
		 */
		NORMAL,
		/**
		 * Treat  extended  data and ordinary data the same. Merge all substreams such that calls to {@link Channel.read} will pull from all substreams on  a first-in/first-out basis.
		 */
		MERGE,
		/**
		 * Discard all extended data as it arrives.
		 */
		IGNORE
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_HOSTKEY_HASH_", has_type_id = false)]
	public enum HashType {
		MD5,
		SHA1
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_KNOWNHOST_")]
	[Flags]
	public enum HostFormat {
		TYPE_MASK,
		/**
		 * ASCII "hostname.domain.tld"
		 */
		TYPE_PLAIN,
		/**
		 * SHA1(<salt> <host>) base64-encoded!
		 */
		TYPE_SHA1,
		/**
		 * Another hash
		 */
		TYPE_CUSTOM,
		KEYENC_MASK,
		KEYENC_RAW,
		KEYENC_BASE64,
		KEY_MASK,
		KEY_SHIFT,
		KEY_RSA1,
		KEY_SSHRSA,
		KEY_SSHDSS
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_INIT_", has_type_id = false)]
	[Flags]
	public enum InitFlags {
		[CCode (cname = "0")]
		NONE,
		/**
		 * Do not initialize the crypto library (i.e., OPENSSL_add_cipher_algoritms() for OpenSSL
		 */
		NO_CRYPTO
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_HOSTKEY_TYPE_", has_type_id = false)]
	public enum KeyType {
		UNKNOWN,
		RSA,
		DSS;
		public HostFormat get_format () {
			switch (this) {
				case RSA:
					return HostFormat.KEY_SSHRSA;
				case DSS:
					return HostFormat.KEY_SSHDSS;
				default:
					return 0;
			}
		}
	}
	[CCode (cname = "int", cprefix = "SSH_METHOD_", has_type_id = false)]
	public enum MethodType {
		KEX,
		HOSTKEY,
		CRYPT_CS,
		CRYPT_SC,
		MAC_CS,
		MAC_SC,
		COMP_CS,
		COMP_SC,
		LANG_CS,
		LANG_SC
	}
	[CCode (cname = "unsigned long", cprefix = "LIBSSH2_SFTP_ST_", cheader_filename = "libssh2_sftp.h")]
	[Flags]
	public enum MountFlags {
		RDONLY,
		NOSUID
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_FLAG_", has_type_id = false)]
	public enum Option {
		/**
		 * Do not attempt to block SIGPIPEs but will let them trigger from the underlying socket layer.
		 */
		SIGPIPE,
		/**
		 * Before the connection negotiation is performed, try to negotiate compression enabling for this connection.
		 *
		 * By default libssh2 will not attempt to use compression.
		 */
		COMPRESS
	}
	[CCode (cname = "long", cprefix = "LIBSSH2_SFTP_RENAME_", cheader_filename = "libssh2_sftp.h")]
	[Flags]
	public enum Rename {
		OVERWRITE,
		ATOMIC,
		NATIVE
	}
	/**
	 * SFTP Status Codes
	 */
	[CCode (cname = "unsigned long", has_type_id = false, cprefix = "LIBSSH2_FX_", cheader_filename = "libssh2_sftp.h")]
	public enum SftpError {
		OK,
		EOF,
		NO_SUCH_FILE,
		PERMISSION_DENIED,
		FAILURE,
		BAD_MESSAGE,
		NO_CONNECTION,
		CONNECTION_LOST,
		OP_UNSUPPORTED,
		INVALID_HANDLE,
		NO_SUCH_PATH,
		FILE_ALREADY_EXISTS,
		WRITE_PROTECT,
		NO_MEDIA,
		NO_SPACE_ON_FILESYSTEM,
		QUOTA_EXCEEDED,
		UNKNOWN_PRINCIPAL,
		LOCK_CONFLICT,
		DIR_NOT_EMPTY,
		NOT_A_DIRECTORY,
		INVALID_FILENAME,
		LINK_LOOP
	}
	[CCode (cname = "int", cprefix = "LIBSSH2_TRACE_", has_type_id = false)]
	[Flags]
	public enum Trace {
		TRANS,
		KEX,
		AUTH,
		CONN,
		SCP,
		SFTP,
		ERROR,
		PUBLICKEY,
		SOCKET
	}
	/**
	 * File Transfer Flags
	 */
	[CCode (cname = "unsigned long", has_type_id = false, cprefix = "LIBSSH2_FXF_", cheader_filename = "libssh2_sftp.h")]
	[Flags]
	public enum Transfer {
		/**
		 * Open the file for reading.
		 */
		READ,
		/**
		 * Open the file for writing. If both this and {@link READ} are specified, the file is opened for both reading and writing.
		 */
		WRITE,
		/**
		 * Force all writes to append data at the end of the file.
		 *
		 * This doesn't have any effect on OpenSSH servers
		 */
		APPEND,
		/**
		 * A new file will be created if one does not already exist (if {@link TRUNC} is specified, the new file will be truncated to zero length if it previously exists)
		 */
		CREAT,
		/**
		 * Forces an existing file with the same name to be truncated to zero length when creating a file by specifying {@link CREAT}. {@link CREAT} MUST also be specified if this flag is used.
		 */
		TRUNC,
		/**
		 * Causes the request to fail if the named file already exists. {@link CREAT} MUST also be specified if this flag is used.
		 */
		EXCL
	}
	/**
	 * Initialize the libssh2 functions.
	 *
	 * This typically initialize the crypto library. It uses a global state, and
	 * is not thread safe -- you must make sure this function is not called
	 * concurrently.
	 * Returns 0 if succeeded, or a negative value for error.
	 */
	[CCode (cname = "libssh2_init")]
	public Error init (InitFlags flags);
	/**
	 * Exit the libssh2 functions and free's all memory used internal.
	 */
	[CCode (cname = "libssh2_exit")]
	public void exit ();
	[CCode (cname = "libssh2_trace_handler_func*", instance_pos = 1.1, simple_generics = true)]
	public delegate void TraceFunc<T> (Session<T> session, [CCode (array_length_type = "size_t")] uint8[] message);
	/**
	 * Part of every banner, user specified or not
	 */
	[CCode (cname = "LIBSSH2_SSH_BANNER")]
	public const string BANNER;
	[CCode (cname = "LIBSSH2_SSH_DEFAULT_BANNER")]
	public const string DEFAULT_BANNER;
	[CCode (cname = "LIBSSH2_SSH_DEFAULT_BANNER_WITH_CRLF")]
	public const string DEFAULT_BANNER_WITH_CRLF;
	[CCode (cname = "LIBSSH2_TERM_HEIGHT")]
	public const int TERM_HEIGHT;
	[CCode (cname = "LIBSSH2_TERM_HEIGHT_PX")]
	public const int TERM_HEIGHT_PX;
	[CCode (cname = "LIBSSH2_TERM_WIDTH")]
	public const int TERM_WIDTH;
	[CCode (cname = "LIBSSH2_TERM_WIDTH_PX")]
	public const int TERM_WIDTH_PX;
}
