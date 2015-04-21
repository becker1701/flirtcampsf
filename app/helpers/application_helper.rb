module ApplicationHelper

	# include MembershipApplicationsHelper

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

	def strf_day(date)
		return nil if date.nil? || 
						(date.class != Date && date.class != Time && date.class != DateTime)

		date.strftime("%a, %b %e")
	end

	def strf_time(time)
		return nil if time.nil? || (time.class != Date && time.class != Time && time.class != DateTime)
		time.strftime("%I:%M %p")
	end

	def event_extended_date_select_formatter(event, date)
		if date == event.start_date
			["#{strf_day(date)} - Event Starts", date]
		elsif date == event.end_date
			["#{strf_day(date)} - Event Ends", date]
		elsif date == event.early_arrival_date
			["#{strf_day(date)} - Early Arrival Starts", date]
		else
			[strf_day(date), date] 
		end
	end
	
	def ea_date_presenter(event)
		if event && event.early_arrival_date
			strf_day(event.early_arrival_date)
		else
			"TBD"
		end
	end



end
