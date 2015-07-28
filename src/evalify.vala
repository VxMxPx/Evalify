// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*
 * Copyright © 2014 Marko Gajst <marko@gaj.st>
 *
 * Licensed under the GNU General Public License Version 2
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using Pango;

public class Evalify : Gtk.Application {

	protected Gtk.TextView result;
	protected Gtk.SourceView source;
	protected ulong source_changed_evnt;
	protected File source_file;

	public Evalify () {
		Object(application_id: "st.gaj.Evalify",
			flags: ApplicationFlags.FLAGS_NONE);
	}

	protected override void activate () {
		// Create Main Window
		Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
		window.set_default_size (600, 400);
		window.title = "Evalify";
		window.key_press_event.connect ((event) => {
			if (event.hardware_keycode == 36 &&
				event.state == Gdk.ModifierType.CONTROL_MASK) {
				execute_code ();
				return true;
			}
			return false;
		});
		window.icon_name = "evalify";

		// Create Header Bar
		Gtk.HeaderBar hbar = new Gtk.HeaderBar ();
		hbar.set_show_close_button (true);
		hbar.set_title ("Evalify");
		hbar.set_subtitle ("Eval PHP Code");
		window.set_titlebar(hbar);

		// Play Button
		Gtk.Button play_button = new Gtk.Button ();
		ThemedIcon play_button_icon = new ThemedIcon ("media-playback-start-symbolic");
		Gtk.Image play_button_image = new Gtk.Image.from_gicon (play_button_icon, Gtk.IconSize.BUTTON);
		play_button.add(play_button_image);
		play_button.clicked.connect(execute_code);
		// Real-time eval button
		Gtk.ToggleButton rt_button = new Gtk.ToggleButton ();
		ThemedIcon rt_button_icon = new ThemedIcon ("view-refresh-symbolic");
		Gtk.Image rt_button_image = new Gtk.Image.from_gicon (rt_button_icon, Gtk.IconSize.BUTTON);
		rt_button_image.opacity = 0.4;
		rt_button.add(rt_button_image);
		rt_button.toggled.connect(() => {
			if (rt_button.get_active() == true) {
				rt_button_image.set_opacity(1);
				source_changed_evnt = source.buffer.changed.connect(execute_code);
			} else {
				rt_button_image.opacity = 0.4;
				source.buffer.disconnect(source_changed_evnt);
			}
		});

		// Add buttons to Header Bar
		hbar.pack_start(play_button);
		hbar.pack_start(rt_button);

		// Scrolled
		Gtk.ScrolledWindow scrolled_result = new Gtk.ScrolledWindow (null, null);
		Gtk.ScrolledWindow scrolled_source = new Gtk.ScrolledWindow (null, null);

		// Make and result to scrolled
		create_result_field ();
		scrolled_result.add (result);

		// Source
		create_source_field ();
		scrolled_source.add (source);

		// Paned
		Gtk.Paned paned = new Gtk.Paned (Gtk.Orientation.VERTICAL);
		paned.border_width = 4;
		paned.pack1 (scrolled_source, true, true);
		paned.pack2 (scrolled_result, false, true);
		paned.position = 260;

		// Add paned
		window.add (paned);

		// Set foucs to source
		source.grab_focus ();

		// Get source file and get its content
		set_source_file ();
		source.buffer.text = read_source_from_file ();

		// Finally show all
		window.show_all ();
	}

	protected void set_source_file () {
		try {
			var home_dir = File.new_for_path (Environment.get_home_dir ());
			var source_dir = home_dir.get_child (".evalify");
			if (!source_dir.query_exists ()) {
				source_dir.make_directory();
			}
			source_file = source_dir.get_child ("evalify-0.php");
			if (!source_file.query_exists ()) {
				source_file.create (FileCreateFlags.PRIVATE);
			}
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}
	protected bool write_source_to_file (string source) {
		try {
			if (source_file.query_exists ()) {
				source_file.delete ();
			}
			var dos = new DataOutputStream (source_file.create (FileCreateFlags.REPLACE_DESTINATION));
			return dos.put_string (source);
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
			return false;
		}
	}
	protected string read_source_from_file () {
		var source = new StringBuilder ();
		try {
			var dis = new DataInputStream (source_file.read ());
			string line;
			while ((line = dis.read_line (null)) != null) {
				source.append (line);
				source.append_c ('\n');
			}
			return source.str;
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
			return "";
		}
	}

	protected void create_result_field () {
		result = new Gtk.TextView ();
		result.editable = false;
		result.is_focus = false;
	}

	protected void create_source_field () {
		// Screate Scheme
		Gtk.SourceStyleSchemeManager scheme = new Gtk.SourceStyleSchemeManager ();
		scheme.set_search_path(null);
		// Create language
		Gtk.SourceLanguageManager language = new Gtk.SourceLanguageManager ();
		// Create buffer
		Gtk.SourceBuffer buffer = new Gtk.SourceBuffer.with_language (language.get_language ("php"));
		buffer.style_scheme = scheme.get_scheme ("tango");
		buffer.highlight_syntax = true;

		Pango.FontDescription font = new Pango.FontDescription ();
		font.set_family("Droid Sans Mono, DejaVu Sans Mono, Ubuntu Mono, Monospace");
		font.set_absolute_size(11 * Pango.SCALE);

		source = new Gtk.SourceView.with_buffer (buffer);
		source.override_font (font);
		source.show_line_numbers = true;
		source.insert_spaces_instead_of_tabs = false;
		source.auto_indent = true;
		source.tab_width = 4;
		source.indent_width = 4;
		source.smart_home_end = Gtk.SourceSmartHomeEndType.ALWAYS;
		source.highlight_current_line = true;
	}

	protected void execute_code () {
		string cout = null;
		string eout = null;

		// Write source
		write_source_to_file (source.buffer.text);

		try {
			// Execute command
			Process.spawn_command_line_sync (
				"/usr/bin/env php -f %s".printf (source_file.get_path ()),
				out cout,
				out eout);
			// Output success or error.
			if (eout == "") {
				result.buffer.text = cout;
			} else {
				result.buffer.text = eout;
			}
		} catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
	}

	public static int main (string[] args) {
		Evalify evalify = new Evalify ();
		return evalify.run (args);
	}
}
