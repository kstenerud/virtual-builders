Virtual Builders
================

Builds somewhat opinionated virtual environments using KVM and LXC/LXD.

I spent quite a lot of time figuring out the best way to set up various environments, and didn't want to lose them to a non-deterministic setup like a server install somewhere, so I've made builders for them.



Usage
-----

Simply run the top level `build.sh` to see what options you have. It will list all environments it can build.

Build.sh is just a launcher for the real build scripts `builders/xyz/build.sh`. You can look inside them to see how they operate, or just call `build.sh xyz -H` to see how to invoke them.

For example, to get help for starting a samba container:

    ./build.sh samba -H

To start a samba container with the hostname "shared" that shares /mnt/myshare as writable under the name "great-stuff":

    ./build.sh samba -n shared -m /mnt/myshare:great-stuff:w

Look at the `README.md` files inside the `builders` subdirs for more information about each virtual environment.



License
-------

Copyright 2018 Karl Stenerud

Released under MIT license https://opensource.org/licenses/MIT

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
