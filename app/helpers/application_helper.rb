module ApplicationHelper

	def full_title(title='')
		base_title = "Flirt Camp SF"

		if title.empty?
			base_title
		else
			"#{title} | #{base_title}"
		end
	end

	def format_newline(text='')
		unless text.empty?
			text.gsub(/\n/, '<br>').html_safe
		end
	end

end
