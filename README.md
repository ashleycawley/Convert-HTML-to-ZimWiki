# Convert-HTML-to-ZimWiki

This script is for anyone who is looking to move away from Microsoft OneNote to Zim Desktop.

It converts OnteNote HTML Pages (Exported via Azure's API using [this method](https://superuser.com/a/1449705)) to ZimWiki format for use with Zim Desktop.

[Zim Desktop](https://zim-wiki.org/) is free, open-source, cross-platform Note Taking application.

Credit to user [danmou](https://superuser.com/users/651502/danmou) on superuser.com who suggested a [working method](https://superuser.com/a/1449705) for extracting Microsoft OneNote Notebooks via Azure's API platform.

The resulting HTML files you're left with are great in that they're more versatile and open than Microsoft's proprietary format, they are still not ideal for Zim Desktop which doesn't allow you to import .html files.

I created this script to convert those HTML files using [_pandoc_](https://pandoc.org/) into a ZimWiki Markup language. This script also sorts a whole host of formatting and structual issues to make the process work.

I hope you find this useful, I've commented the code so you can see what is going on. I'm not bash guru so please be kind and feel free to contribute improvements if you wish.

## Development Notes
Things to do next:
- ~Take the document title and insert that as a title within the .txt document.~
- ~Backup original fileset before processing.~
- ~Handle the archiving / removal of the old HTML files which are no longer required.~
- Investigate potential problems with comma's in article names, one that potentially ran into issues:
_Product Names, Terminology, Explanations_
