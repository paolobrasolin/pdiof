# pdiof

This is a quick and dirty script to find and extract occurences of integration symbols from PDF documents.

## Usage

Clone the repo

```
git clone https://github.com/paolobrasolin/pdiof.git
```

Then install the dependencies. If you are using RVM

```
cd pdiof
gem install bundler
bundle install
```

and if you are not then just

```
cd pdiof
gem install hexapdf
```

You can now run the script:

```
ruby pdiof.rb input.pdf output.pdf
# => Found occurrences of ∫ on pages [42, 666] of input.pdf.
# => Saving them to output.pdf...
```

Et voilà, relevant pages have been extracted! Enjoy.

