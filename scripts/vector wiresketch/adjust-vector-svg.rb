#!/usr/bin/ruby
#
# Adjust SVG files to fit into square, 32x32 viewport, and use black color
#

require 'rexml/document'

root = File.join(File.dirname(__FILE__), '../..')
input_dir = File.join(root, 'vector')
output_dir = File.join(root, 'vector wiresketch')

FileUtils.mkdir_p(output_dir)

def adjust_colors(element)
	style = element.attributes['style']
	if style
		element.attributes['style'] = style.gsub(/fill:\#[0-9a-f]{3,6}/i, 'fill:#000000')
	end

	element.elements.each do |child|
		adjust_colors(child)
	end
end

Dir["#{input_dir}/*.svg"].each do |input_svg|
	output_svg = File.join(output_dir, File.basename(input_svg))

	doc = REXML::Document.new(File.open(input_svg))

	viewBox = doc.root.attributes['viewBox'].split.map {|s| s.to_f}
	width = viewBox[2]
	height = viewBox[3]

	if width != 32 || height != 32
		doc.root.attributes['width'] = '32px'
		doc.root.attributes['height'] = '32px'

		min_x = -((32 - width) / 2).to_i
		min_y = -((32 - height) / 2).to_i

		doc.root.attributes['viewBox'] = "#{min_x} #{min_y} 32 32"
	end

	adjust_colors(doc.root)
	doc.root.delete_attribute('style')

	File.open(output_svg, 'w') do |out|
		doc.write(out)
	end
end
