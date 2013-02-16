require 'ansi/code'

module Assert::View::Helpers

  module AnsiStyles

    def result_ansi_styles(result)
      view.styled ? view.send("#{result.to_sym}_styles") : []
    end

    def ansi_styled_msg(msg, styles=[])
      if !(style = ansi_style(*styles)).empty?
        style + msg + ANSI.send(:reset)
      else
        msg
      end
    end

    def ansi_style(*ansi_codes)
      ansi_codes.collect{|code| ANSI.send(code) rescue nil}.compact.join('')
    end

  end

end
