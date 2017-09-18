/*
* Copyright (c) 2011-2017 Alecaddd (http://alecaddd.com)
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

public class Sequeler.FileManager {
    //  public const string FILE_EXTENSION = ".txt";

    //  public static File? current_file = null;

    //  public static File? new_connection (Gee.HashMap<string, string> data) {
    //      File? result = null;

    //      var documents = Environment.get_user_special_dir (UserDirectory.DOCUMENTS) + "/%s".printf (_("Connections"));
    //      DirUtils.create_with_parents (documents, 0775);

    //      result = File.new_for_path ("%s/%s%s".printf (documents, data["title"], FILE_EXTENSION));

    //      if (result.query_exists ()) {
    //          result.delete ();
    //      }

    //      var to_save = serialize_data (data);

    //      GLib.FileUtils.set_data (result.get_path (), to_save);

    //      settings.add_connection (result.get_path ());

    //      return result;
    //  }

    //  public static uint8[] serialize_data (Gee.HashMap<string, string> data) {
    //      string result = "";

    //      foreach (var entry in data.entries) {

    //          if (entry.key == "password") {
    //              store_password (data["username"], data["name"], entry.value);
    //              continue;
    //          }

    //          string values = "%s=%s\n".printf (entry.key, entry.value);
    //          result = result + values;
    //      }

    //      uint8[] test = result.data;

    //      return test;

    //  }

    //  public static void delete_connection (File file = current_file) {
    //      if (file != null && file.query_exists () && file.get_basename ().contains (FILE_EXTENSION)) {
    //          FileUtils.remove (file.get_path ());
    //      }
    //  }

}