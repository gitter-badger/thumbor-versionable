require 'spec_helper'

describe Versionable do

  class FakeClass
    include Versionable

    imageable :image, :external_fake_image do
      version :form_thumbnail, width: 100, height: 150 do
        filter :quality, 50
      end
      version :form_thumbnail_2, width: 100, height: 150
    end
  end

  let(:fake_product) do
    fake_product = FakeClass.new
    fake_product.stub(:external_fake_image) { "http://google.com/favicon.ico" }
    fake_product
  end

  it "adds :imageable to the class" do
    expect(FakeClass).to respond_to(:imageable)
  end

  it "should responds to the method specified" do
    expect(fake_product).to respond_to(:image)
  end

  describe Versionable::Image do

    it "should responds to :url" do
      expect(fake_product.image).to respond_to(:url)
      expect(fake_product.image.url).to eq("http://google.com/favicon.ico")
    end

    it "should responds to version" do
      expect(fake_product.image).to respond_to(:form_thumbnail)
      expect(fake_product.image).to respond_to(:form_thumbnail_2)
    end

    it "should be rendered as a json" do
      expect(fake_product.image).to respond_to(:to_json)
      expect(fake_product.image.to_json).to eq('{"url":"http://google.com/favicon.ico","form_thumbnail":{"url":"http://d1bh8njmv27xmo.cloudfront.net/bUsCCZFT0TMPVoSfCu5JRLgJdsA=/100x150/filters:quality(50)/http://google.com/favicon.ico"},"form_thumbnail_2":{"url":"http://d1bh8njmv27xmo.cloudfront.net/JafVjn15T0CXvQ9GsdkwyMDBS_U=/100x150/http://google.com/favicon.ico"}}')
    end

    context "when the image is valid" do
      let :metadata do
        {"thumbor"=>{"operations"=>[], "source"=>{"url"=>"http://google.com/favicon.ico", "width"=>32, "height"=>32}, "focal_points"=>[{"origin"=>"alignment", "height"=>1, "width"=>1, "y"=>16.0, "x"=>16.0, "z"=>1.0}], "target"=>{"width"=>32, "height"=>32}}}
      end
      it "should fetch the image metadata" do
        expect(fake_product.image).to respond_to(:fetch_metadata)
      end

      it "should be able to set height from the metadata" do
        expect(fake_product.image.set_height_from_metadata metadata).to eq(32)
      end

      it "should be able to set the width from the metadata" do
        expect(fake_product.image.set_width_from_metadata metadata).to eq(32)
      end
    end

    context "when the image is invalid" do
      let(:metadata) { "" }

      it "setting the height from the metadata should throw an exception" do
        expect { fake_product.image.set_height_from_metadata metadata }.to raise_exception
      end
      it "setting the width from the metadata should throw an exception" do
        expect { fake_product.image.set_width_from_metadata metadata }.to raise_exception
      end
    end

    describe Versionable::Version do
      it "should responds to :url" do
        expect(fake_product.image.form_thumbnail).to respond_to(:url)
        expect(fake_product.image.form_thumbnail_2).to respond_to(:url)
      end

      it "should correctly constructs the url" do
        expect(fake_product.image.form_thumbnail.url).to eq('http://d1bh8njmv27xmo.cloudfront.net/bUsCCZFT0TMPVoSfCu5JRLgJdsA=/100x150/filters:quality(50)/http://google.com/favicon.ico')
        expect(fake_product.image.form_thumbnail_2.url).to eq('http://d1bh8njmv27xmo.cloudfront.net/JafVjn15T0CXvQ9GsdkwyMDBS_U=/100x150/http://google.com/favicon.ico')
      end

      context "when the image is valid" do
        it "correctly calculate it metadata" do
          expect(fake_product.image.form_thumbnail.calculate_metadata).to eq({
            width: 100,
            height: 150
            })
        end
      end
    end
  end
end
