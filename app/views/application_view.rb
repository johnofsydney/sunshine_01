# frozen_string_literal: true

class ApplicationView < ApplicationComponent
	# The ApplicationView is an abstract class for all your views.

	# By default, it inherits from `ApplicationComponent`, but you
	# can change that to `Phlex::HTML` if you want to keep views and
	# components independent.

  def button_styles(instance)
    {
      'background_color' => background_color(instance),
      'color' => color(instance)
    }.map{|key, value| "#{key.to_s.dasherize}: #{value};"}
     .join('; ') + ';'

  end

  def background_color(item)
    background_color = safe_name(item)
    "#" + text_to_hex(background_color)
  end

  def color(item)
    text_to_hex(safe_name(item)).hex > 0x7FFFFF ? 'black' : 'white'
  end

  def text_to_hex(text)
    Digest::MD5.hexdigest(text)[0..5]
  end

  def safe_name(item)
    item.attributes['name'] || item.attributes['amount'].to_s
  end

  def class_of(klass)
    return 'groups' if klass.respond_to?(:report_as) && klass.report_as == 'group'

    klass.is_a?(Group) ? 'groups' : 'people'
  end
end
