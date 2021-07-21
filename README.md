# Javascript Calculator

A Javascript calculator developed for the Think Through Math product,
released to the world as open source.

## Usage

See examples and usage as documented on the
[demo page](http://thinkthroughmath.github.io/javascript-calculator).

## `ttm-coffeescript-math`

The JavaScript Calculator leans heavily upon the
`ttm-coffeescript-math` library, which is provides all of its
mathematical logic.


## Developing

0. Install Node.js if you haven't already
   (http://nodejs.org/download/), or use your system's package manager.

1. Clone the repository:

```
git clone git@github.com:thinkthroughmath/javascript-calculator.git
cd javascript-calculator
```

2. Start a Docker Container
Run all the following commands within the container session
This assumes you use SSH keys to clone github repos
```
docker run --rm -it -e OPENSSL_CONF=/dev/null  -v ~/.ssh:/root/.ssh:ro -v `pwd`:/srv/javascript-calculator -w /srv/javascript-calculator ruby:2.7.3-buster bash
```

3. Install pre-resquisites:

```
gem install sass
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash && . ~/.bashrc
nvm install 0.10
npm install -g grunt@0.4.1 grunt-cli@1.2 bower
```

4. Install the required packages:

```
npm install
```

5. Install the bower packages:
```
bower install
```

6. Start the development server:
```
grunt serve
```

7. In order to run the tests:

```
grunt test
```
This will also rebuild the dist/production version of the JS

## License

The MIT License (MIT)

Copyright (c) 2013 Think Through Learning Inc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
