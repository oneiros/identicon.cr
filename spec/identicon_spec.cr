require "./spec_helper"

describe Identicon do
  Spec.before_each do
    Dir.mkdir("tmp") unless File.directory?("tmp")
  end

  # general parameter tests
  it "creates a binary string image blob" do
    Identicon.create("Identicon").should be_a(String)
  end

  it "does not create a binary string image blob with an invalid key" do
    expect_raises(Exception, "key is less than 16 bytes") do
      Identicon.create("identicons are great!", key: "\x00\x11\x22\x33\x44")
    end
  end

  it "does not create a binary string image blob with an invalid grid size" do
    expect_raises(Exception, "grid_size must be between 4 and 9") do
      Identicon.create("Identicon", grid_size: 2)
    end
    expect_raises(Exception, "grid_size must be between 4 and 9") do
      Identicon.create("Identicon", grid_size: 20)
    end
  end

  it "does not create a binary string image blob with an invalid square_size size" do
    expect_raises(Exception, "invalid square size") do
      Identicon.create("Identicon", square_size: -2)
    end
  end

  it "does not create a binary string image blob with an invalid border_size size" do
    expect_raises(Exception, "invalid border size") do
      Identicon.create("Identicon", border_size: -2)
    end
  end

  # blob creation tests
  it "creates a png image file" do
    blob = Identicon.create("Identicon")
    result = File.open("tmp/identicon.png", "wb") { |f| f << blob }
    result.should be_truthy
  end

  it "creates a png image file of grid size 5, square size 70 and grey background" do
    blob = Identicon.create("Identicon", grid_size: 5, square_size: 70, background_color: "#f0f0f0", key: "1234567890123456")
    result = File.open("tmp/identicon_gs5_white.png", "wb") { |f| f << blob }
    result.should be_truthy
  end

  it "creates 10 png image files" do
    10.times do |count|
      blob = Identicon.create("Identicon_#{count}")
      result = File.open("tmp/identicon_#{count}.png", "wb") { |f| f << blob }
      result.should be_truthy
    end
  end

  # file creation tests
  it "creates a png image file via create_and_save" do
    result = Identicon.create_and_save("Identicon is fun", "tmp/test_identicon.png")
    result.should be_truthy
  end

  # Base64 creation tests
  it "creates base64 version of the image" do
    blob = Identicon.create("Identicon")
    base64 = Identicon.create_base64("Identicon")
    Base64.decode_string(base64).should eq blob
  end
end
