require 'spec_helper'

describe "Namespaces example" do

  let(:file) { File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'mods_document.xml'), 'r') }
  let(:xml) { Nokogiri::XML(file) }

  subject {

     xml.set_terminology(:namespaces => { 'mods' => 'http://www.loc.gov/mods/v3'}) do |t|

      t.author :path => '//mods:name' do |n|
        n.valueURI :path => '@valueURI', :accessor => lambda { |node| node.to_s }
        n.namePart :path => 'mods:namePart'   
      end

      t.corporate_authors :path => '//mods:name[@type="corporate"]'
      t.personal_authors :path => 'mods:name[@type="personal"]' do |n|
        n.roleTerm :path => 'mods:role/mods:roleTerm'

        n.name_role_pair :path => '.', :accessor => lambda { |node| node.roleTerm.text + ": " + node.namePart.text }

    #    n.name_object :path => '.', :accessor => lambda { |node| ModsName.new node }
      end

      t.language :path => 'mods:language' do |n|
        n.value :path => 'mods:languageTerm', :accessor => :text
      end
     
     end

     xml.nom!

     xml
  }

  it "should share terms over matched nodes" do
    subject.personal_authors.first.namePart.text.should == "Alterman, Eric"
  end

  it "should create enumerable objects" do
    subject.personal_authors.should respond_to(:each)
    subject.personal_authors.should have(1).node
  end

  it "should provide accessors" do
    eric =subject.personal_authors.first
 
    eric.namePart.text.should == "Alterman, Eric"
    eric.roleTerm.text.should == "creator"
  end

  it "should let you mix and match xpaths and nom accessors" do
    subject.language.value.should include('eng')
    subject.xpath('//mods:language', 'mods' => 'http://www.loc.gov/mods/v3').value.should include('eng')
  end

  it "should work with attributes" do
    eric =subject.personal_authors.first
    eric.valueURI.should include('http://id.loc.gov/authorities/names/n92101908')
  end

end
