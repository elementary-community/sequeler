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

public interface DataBaseType : Object {
	/*
	 * Connect to the database
	 */
	public abstract string connection_string (Gee.HashMap<string, string> data);

	/*
	 * Populate dropdown database selection
	 */
	public abstract string show_schema ();

	/*
	 * Populate sidebar with table list
	 */
	public abstract string show_table_list (string name);

	/*
	 * Update table name
	 */
	public abstract string edit_table_name (string old_table, string new_table);

	/*
	 * Show table structure
	 */
	public abstract string show_table_structure (string table);

	/*
	 * Show table content
	 */
	public abstract string show_table_content (string table, int? count);

	/*
	 * Show table relations
	 */
	public abstract string show_table_relations (string table, string? database);
}
