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

public class Sequeler.Services.Types.PostgreSQL : Object, DataBaseType {
    public string port { set; get; default = "5432"; }

    public string connection_string (Gee.HashMap<string, string> data) {
        var username = Gda.rfc1738_encode (data["username"]);
        var password = Gda.rfc1738_encode (data["password"]);
        var name = Gda.rfc1738_encode (data["name"]);
        var host = Gda.rfc1738_encode (data["host"]);
        port =  data["port"] != "" ? data["port"] : port;

        return "PostgreSQL://" + username + ":" + password + "@DB_NAME=" + name + ";HOST=" + host + ";PORT=" + port;
    }
}