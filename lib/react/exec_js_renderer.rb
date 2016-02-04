require "execjs"

module React
  class ExecJSRenderer
    def initialize(code)
      @context = ExecJS.compile(GLOBAL_WRAPPER + code)
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
      js_code = <<-JS
        (function () {
          return ReactDOMServer.#{render_function}(
            React.createElement(#{component_name}, #{json_props})
          );
        })()
      JS

      @context.eval(js_code)
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
