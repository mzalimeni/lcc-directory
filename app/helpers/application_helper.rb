module ApplicationHelper

   BASE_TITLE="LCC Online Directory"

   #Returns the full title on a per-page basis
   def full_title(page_title)
      if page_title.empty?
        BASE_TITLE
      else
        "#{BASE_TITLE} | #{page_title}"
      end
   end

end
