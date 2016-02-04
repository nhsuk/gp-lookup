require "execjs"

module React
  class ExecJSRenderer
    def initialize(component_js_files)
      @component_js_files = component_js_files
    end

    def render_static_markup(component_name, props = {})
      render(
        component_name,
        props,
        render_function: "renderToStaticMarkup",
        wrap_component: false,
      )
    end

    def render(component_name, props, options = {})
      options = default_render_options.merge(options)
      props = props.to_json unless props.is_a?(String)

      component = render_component(
        component_name,
        props,
        options.fetch(:render_function),
      )

      if options.fetch(:wrap_component)
        wrapper = component_wrapper(
          options.fetch(:wrapper_element),
          options.fetch(:component_name_attribute),
          options.fetch(:props_attribute),
          component_name,
          props,
        )

        [
          wrapper.first,
          component,
          wrapper.last,
        ].join
      else
        component
      end
    end

  private
    attr_reader :component_js_files

    def default_render_options
      {
        render_function: "renderToString",
        wrap_component: true,
        wrapper_element: "div",
        component_name_attribute: "data-react-class",
        props_attribute: "data-react-props",
      }
    end

    def render_component(component_name, json_props, render_function)
      code_to_eval = <<-JS
        (function () {
          return ReactDOMServer.#{render_function}(
            React.createElement(#{component_name}, #{json_props})
          );
        })()
      JS

      context.eval(code_to_eval)
    rescue ExecJS::ProgramError => err
      raise PrerenderError.new(component_name, props, err)
    end

    def component_wrapper(wrapper_element,
                          component_name_attribute,
                          props_attribute,
                          component_name,
                          json_props)

      wrapper_attributes = html_attributes(
        component_name_attribute => component_name,
        props_attribute => json_props,
      )

      [
        "<#{wrapper_element} #{wrapper_attributes}>",
        "</#{wrapper_element}>",
      ]
    end

    def html_attributes(attributes)
      attributes.map { |key, value|
        %(#{key}="#{CGI::escapeHTML(value)}")
      }.join(" ")
    end

    def context
      @context ||= ExecJS.compile(GLOBAL_WRAPPER + js_code)
    end

    def js_code
      @js_code ||= js_files.map { |file_name| File.read(file_name) }.join(";")
    end

    def js_files
      react_js_files + component_js_files
    end

    def react_js_files
      ["public/javascripts/react-server.js"]
    end

    # Handle Node.js & other ExecJS contexts
    GLOBAL_WRAPPER = <<-JS
      var global = global || this;
      var self = self || this;
      var window = window || this;
    JS
  end

  class PrerenderError < RuntimeError
    def initialize(component_name, props, js_message)
      message = [
        "Encountered error \"#{js_message}\" when prerendering #{component_name} with #{props}",
        js_message.backtrace.join("\n"),
      ].join("\n")
      super(message)
    end
  end
end
