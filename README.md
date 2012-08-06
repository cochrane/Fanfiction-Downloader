Fanfiction-Downloader
=====================

The Fanfiction Downloader is a Mac OS X app to track stories [FanFiction.net][] and send them to your Kindle. When you click the "Update" button, it check which stories have been changed since the last time and then send them via E-mail to [Amazon][]. As soon as Amazon has processed the file, it will be ready for download to your Kindle, either right away or the next time WLAN is available.

This is heavily inspired by [cryzed's Lemon][lemon] python script, but with a graphical user interface, and written completely in Objective C. The only actual code I copied (with adaptions) was the HTML template.

Getting started
---------------

1.	Download the newest version from "Downloads".
2.	When it first runs, it will ask you for your Kindle's email address and your sender email address. The sender email address has to be one that Mail can use.
3.	Add stories, either by clicking "+" or by dragging and dropping story URLs into the story window.
4.	Send the stories to your Kindle by clicking the update button (lower right).

If you've previously used Lemon, you can import your stories.ini file here. Note that because this tool uses a different way of determining when a story has changed, it will initially send all stories to your Kindle again.


[FanFiction.net]: http://fanfiction.net/
[Amazon]: http://amazon.com/
[lemon]: https://github.com/cryzed/lemon