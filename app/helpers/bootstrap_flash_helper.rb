module BootstrapFlashHelper
  ALERT_TYPES = [:danger, :error, :alert, :info, :success, :warning, :notice]

  def flash_messages?
    ALERT_TYPES.any? {|type| flash.key?(type) }
  end

  def bootstrap_flash
    flash_messages = []

    # Hack to make this play nice with Devise controllers
    if defined?(Devise) && defined?(resource) && !resource.nil? && resource.try(:errors).try(:to_a).try(:any?)
      flash[:alert] ||= []
     flash[:alert].concat resource.errors.full_messages
    end

    flash.each do |type, message|
      # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
      next if message.blank?

      type = :info if type == :notice
      type = :danger  if [:alert, :error].include? type
      if not ALERT_TYPES.include?(type)
        Rails.logger.debug "Unknown Bootstrap alert type #{type}. Not rendering flash message #{message}. Edit bootstrap_flash_helper.rb to change this behavior."
      end

      Array(message).each do |msg|
        if msg.is_a? Array
          msg = msg.flatten.join ', '
        elsif !msg.is_a? String
          msg = msg.to_s
        end

        text = content_tag(:div,
                           content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert", 'aria-hidden' => true) +
                           msg.html_safe, :class => "alert alert-#{type} alert-dismissable fade in")
        flash_messages << text if msg
      end
    end
    flash_messages.join("\n").html_safe
  end
end
