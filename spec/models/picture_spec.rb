require "spec_helper"

describe Picture do
  subject { FactoryGirl.build :picture }

  it "auto-creates needed directory" do
    expect(File.directory?(described_class.directory)).to be_true
  end

  it "#content" do
    subject.content.should.nil?
    expected = "FOOBAR"
    subject.content         = expected.dup
    expect(subject.content).to eq expected
  end

  context "#extension" do
    it "on new record" do
      subject.extension.should.nil?
      ext = "foo"
      subject.extension         = ext.dup
      expect(subject.extension).to eq ext

      subject.save

      p = described_class.first
      expect(p.extension).to eq ext

      subject.reload
      expect(subject.extension).to eq ext
    end

    it "on existing record" do
      subject.save

      subject.reload
      subject.extension.should.nil?
      ext = "foo"
      subject.extension         = ext.dup
      expect(subject.extension).to eq ext

      subject.save

      p = described_class.first
      expect(p.extension).to eq ext

      subject.reload
      expect(subject.extension).to eq ext
    end
  end

  it "#size" do
    expect(subject.size).to eq 0
    expected = "FOOBAR"
    subject.content         = expected.dup
    expect(subject.size).to eq expected.length
  end

  context "#basename" do
    it "fails when record is new" do
      -> { subject.filename }.should raise_error
    end

    context "works when record is saved" do
      it "without extension" do
        subject.save
        expect(subject.basename).to eq "#{subject.compressed_id}."
      end

      it "with extension" do
        subject.extension = "png"
        subject.save
        expect(subject.basename).to eq "#{subject.compressed_id}.#{subject.extension}"
      end
    end
  end

  it "#filename" do
    basename = "foo.bar"
    subject.stub(:basename).and_return(basename)
    expect(subject.filename).to eq File.join(Picture.directory, basename)
  end

  it "#url_path" do
    basename = "foo.bar"
    subject.stub(:basename).and_return(basename)
    expect(subject.url_path).to eq "/pictures/#{basename}"
  end
end
