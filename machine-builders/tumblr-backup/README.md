Tumblr Backup
=============

Backup Tumblr blogs daily at 1:25.


Required Files
--------------

You must put a file called blogs.csv in the root of the blog backup dir. It will have the format:

    [blog name],[minimum characters]

Where:

  * [blog name] is the name of the blog, such that [blog name].tumblr.com is the URL of the blog.
  * [minimum characters] is an integer representing the minimum number of characters in a post before it is saved.

Example:

    yahoo,500
    yahooeng,0



Blog Backup Directory
---------------------

Use the -m option:

    -m /path/to/blog/backup/dir

This directory MUST contain blogs.csv
