# identicon.cr

Create github-style identicons

This is a straight port of Chris Branson's [ruby_identicon](https://github.com/chrisbranson/ruby_identicon), which is a Ruby implementation of [go-identicon](https://github.com/dgryski/go-identicon) by Damian Gryski

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  identicon:
    github: oneiros/identicon.cr
```

## Usage

```crystal
require "identicon"
```

Creating an identicon and saving to png

```crystal
Identicon.create_and_save("Identicon", "identicon.png")
```

Creating an identicon and returning a binary string

```crystal
blob = Identicon.create("Identicon")

# optional, save to a file
File.open("identicon.png", "wb") do |f|
  f << blob
end
```

Creating an identicon and returning in Base64 format

```crystal
base64_identicon = Identicon.create_base64("Identicon")
```

to render this in HTML, pass the Base64 code into your template: 

```html
<img src='data:image/png;base64,<%= base64_identicon %>'>
```

## Customising the identicon

The identicon can be customised by passing additional options

    background_color:  (String, default "#00000000") the background color of the identicon in hex notation (e.g. "#ffffff" for white)
    border_size:  (Int32, default 35) the size in pixels to leave as an empty border around the identicon image
    grid_size:    (Int32, default 7)  the number of rows and columns in the identicon, minimum 4, maximum 9
    square_size:  (Int32, default 50) the size in pixels of each square that makes up the identicon
    key:          (String) a 16 byte key used by siphash when calculating the hash value (see note below)

    Varying the key ensures uniqueness of an identicon for a given title, it is assumed desirable for different applications to use a different key.

Example

```crystal
blob = Identicon.create("identicons are great!", grid_size: 5, square_size: 70, background_color: "#f0f0f0ff", key: "1234567890123456")
File.open("tmp/test_identicon.png", "wb") { |f| f << blob }
 ```

## Contributing

1. Fork it (<https://github.com/oneiros/identicon/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [oneiros](https://github.com/oneiros) David Roetzel - creator, maintainer

With many thanks to:
- [chrisbranson](https://github.com/chrisbranson) Chris Branson - for `ruby_identicon`
- [dgryski](https://github.com/dgryski) Damian Gryski - for the original golang implementation
- [ysbaddaden](https://github.com/ysbaddaden) Julien Portalier - for the excellent crystal siphash library
- [l3kn](https://github.com/l3kn) Leon Rische - for `stumpy_png`
