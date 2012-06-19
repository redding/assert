module Assert::View::Helpers

  module CaptureOutput

    def captured_output(output)
      if !output.empty?
        # TODO: move to the base view
        [ captured_output_start_msg,
          output + captured_output_end_msg
        ].join("\n")
      end
    end

    def captured_output_start_msg
      "--- stdout ---"
    end
    def captured_output_end_msg
      "--------------"
    end

  end

end
