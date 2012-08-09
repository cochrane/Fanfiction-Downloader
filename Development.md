Development
===========

To build this, you need the DMLocalizedNibBundle project. The easiest way to get it is to first clone this repository, then use

	git submodule sync
	git submodule update --init

That will take care of the rest. The project is written with Xcode 4.4, but may work with earlier versions, too.

Translating
-----------

All translation is handled only in the .strings files; there is no need to change the .xib files. The .strings files for english are automatically updated on every build; to get the newest version, extract them from the app bundle.
