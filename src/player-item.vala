/*
Copyright 2010 Canonical Ltd.

Authors:
    Conor Curran <conor.curran@canonical.com>

This program is free software: you can redistribute it and/or modify it 
under the terms of the GNU General Public License version 3, as published 
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranties of 
MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR 
PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along 
with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

using Dbusmenu;
using Gee;

public class PlayerItem : Dbusmenu.Menuitem
{
	public MprisController mpris_adaptor;
	
	public PlayerItem()
	{		
	}

	public void reset(HashSet<string> attrs){		
		foreach(string s in attrs){
			debug("attempting to set prop %s to null", s);
			this.property_set(s, null);
		}
	}
	
	public void update(HashTable<string, Value?> data, HashSet<string> attributes)
	{
		debug("PlayerItem::update()");
		if(ensure_valid_updates(data, attributes) == false){
			debug("PlayerItem::Update -> The hashtable update does not contain what we were expecting - just leave it!");
			return;
		}
		foreach(string property in attributes){
			string[] input_keys = property.split("-");
			string search_key = input_keys[input_keys.length-1 : input_keys.length][0];
			debug("search key = %s", search_key);
			Value? v = data.lookup(search_key);
			
			if (v.holds (typeof (string))){
				debug("with value : %s", v.get_string());
				this.property_set(property, this.sanitize_string(v.get_string()));
			}			    
			else if (v.holds (typeof (int))){
				debug("with value : %i", v.get_int());
				this.property_set_int(property, v.get_int());
			}
			else if(v.holds (typeof (bool))){
				this.property_set_bool(property, v.get_boolean());
			}
		}
		// TODO: not working
		//this.check_layout();
	}	

	public void set_adaptor(MprisController adaptor)
	{
		this.mpris_adaptor = adaptor;		
	}

	private static bool ensure_valid_updates(HashTable<string, Value?> data, HashSet<string> attributes)
	{
		if(data == null){
			return false;
		}
		if(data.size() < attributes.size){
			warning("update hash was too small for the target");
			return false;
		}
		return true;		
	}

	public static string sanitize_string(string st)
	{
		string result = st.strip();
		if(result.has_prefix("file:///")){
			result = result.slice(7, result.len());		                   
		}
		debug("Sanitize string - result = %s", result);
		return result;
	}

	
	//----- Custom constructors for player items ----------------//
	// Title item
	public static PlayerItem new_title_item(dynamic string name)
	{
		PlayerItem item = new PlayerItem();
		item.property_set(MENUITEM_PROP_LABEL, name);					
		item.property_set(MENUITEM_PROP_ICON_NAME, "applications-multimedia");			
		return item;		
	}

	// Separator item
	public static PlayerItem new_separator_item()
	{
		PlayerItem separator = new PlayerItem();
		separator.property_set(MENUITEM_PROP_TYPE, CLIENT_TYPES_SEPARATOR);					
		return separator;
	}	

	public virtual void check_layout(){
		warning("this should not be hit");
	}
}

