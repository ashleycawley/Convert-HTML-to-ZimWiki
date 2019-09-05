# Convert-HTML-to-ZimWiki

This script is for anyone who is looking to *move away from Microsoft OneNote to Zim Desktop*.

This script can convert hundreds of OnteNote HTML Pages (Exported via Azure's API using [this method](https://superuser.com/a/1449705)) to ZimWiki format for use with Zim Desktop. [Zim Desktop](https://zim-wiki.org/) is free, open-source, cross-platform Note Taking application.

Credit to user [danmou](https://superuser.com/users/651502/danmou) on superuser.com who suggested a [working method](https://superuser.com/a/1449705) for extracting Microsoft OneNote Notebooks via Azure's API platform.

The resulting HTML files you're left with are great in that they're more versatile and open than Microsoft's proprietary format, however they are still not ideal for Zim Desktop which does not allow you to import .html files.

I created this script to convert those HTML files using [_pandoc_](https://pandoc.org/) into a ZimWiki Markup language. This script also fixes a whole host of formatting and structual issues to make the process work.

I hope you find this useful, I've commented the code so you can see what is going on. I'm not bash guru so please be kind and feel free to contribute improvements if you wish.

For the sake of completeness I will list *_danmou's_ guide at the bottom of this article* that describes how to export your OneNote Notebook via the Azure API (_just incase anything ever happens to the SuperUser page_).

## Development Notes
Things to do next:
- ~Take the document title and insert that as a title within the .txt document.~
- ~Backup original fileset before processing.~
- ~Handle the archiving / removal of the old HTML files which are no longer required.~
- Investigate potential problems with comma's in article names, one that potentially ran into issues:
_Product Names, Terminology, Explanations_

## Exporting OneNote Notebooks from Azure API
Source: Posted by [danmou](https://superuser.com/users/651502/danmou) on June 2019.
I found a solution using Microsoft's Graph API. This means you don't even have to run OneNote, it just requires that your notes are synced to your Microsoft account and then you can get your notes as perfectly formatted HTML (which you can view in the browser or convert to whatever format you prefer using Pandoc).

The magic happens in this Python script. It runs a simple local web server that you can use to log in to your Microsoft account and once you do that it downloads all your notes as HTML, plus images and attachments in their original formats, and stores them in file hierarchy preserving the original structure of your notebooks (including page order and subpages).

Before you can run the script, you have to register an "app" in Microsoft Azure so it can access the Graph API:

Go to https://aad.portal.azure.com/ and log in with your Microsoft account.
Select "Azure Active Directory" and then "App registrations" under "Manage".
Select "New registration". Choose any name, set "Supported account types" to "Accounts in any organizational directory and personal Microsoft accounts" and under "Redirect URI", select Web and enter http://localhost:5000/getToken. Register.
Copy the "Application (client) ID" and paste it as client_id in the beginning of the Python script.
Select "Certificates & secrets" under "Manage". Press "New client secret", choose a name and confirm.
Copy the client secret and paste it as secret in the Python script.
Select "API permissions" under "Manage". Press "Add a permission", scroll down and select OneNote, choose "Delegated permissions" and check "Notes.Read" and "Notes.Read.All". Press "Add permissions".
Then you need to install the Python dependencies. Make sure you have Python 3.7 (or newer) installed and install the dependencies using the command pip install flask msal requests_oauthlib.

Now you can run the script. In a terminal, navigate to the directory where the script is located and run it using python onenote_export.py. This will start a local web server on port 5000.

In your browser navigate to http://localhost:5000 and log in to your Microsoft account. The first time you do it, you will also have to accept that the app can read your OneNote notes. (This does not give any third parties access to your data, as long as you don't share the client id and secret you created on the Azure portal). After this, go back to the terminal to follow the progress.

Note: Microsoft limits how many requests you can do within a given time period. Therefore, if you have many notes you might eventually see messages like this in the terminal: Too many requests, waiting 20s and trying again. This is not a problem, but it means the entire process can take a while. Also, the login session can expire after a while, which results in a TokenExpiredError. If this happens, simply reload http://localhost:5000 and the script will continue (skipping the files it already downloaded).