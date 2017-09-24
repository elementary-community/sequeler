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

public class Sequeler.DataBase : Object {
    /* Using defaults will search a SQLite database located at current directory called test.db */
    public string provider { set; get; default = "SQLite"; }
    //  public string constr { set; get; default = "SQLite://DB_DIR=.;DB_NAME=test"; }
    public string constr { set; get; default = "MySQL://DB_NAME=wp;HOST=127.0.0.1;USERNAME=root;PASSWORD=admin"; }
    public Gda.Connection cnn;
    
    public void open () throws Error {
        stdout.printf("Opening Database connection...\n");
        this.cnn = Gda.Connection.open_from_string (null, this.constr, null, Gda.ConnectionOptions.NONE);
    }

    /* Create a tables and populate them */
    public void create_tables () 
            throws Error
            requires (this.cnn.is_opened())
    {
            stdout.printf("Creating and populating data...\n");
            this.run_query("CREATE TABLE test (description string, notes string)");
            this.run_query("INSERT INTO test (description, notes) VALUES (\"Test description 1\", \"Some notes\")");
            this.run_query("INSERT INTO test (description, notes) VALUES (\"Test description 2\", \"Some additional notes\")");
            
            this.run_query("CREATE TABLE table1 (city string, notes string)");
            this.run_query("INSERT INTO table1 (city, notes) VALUES (\"Mexico\", \"Some place to live\")");
            this.run_query("INSERT INTO table1 (city, notes) VALUES (\"New York\", \"A new place to live\")");
    }
    
    public int run_query (string query) 
            throws Error
            requires (this.cnn.is_opened())
    {
            stdout.printf("Executing query: [%s]\n", query);
            return this.cnn.execute_non_select_command (query);
    }
}