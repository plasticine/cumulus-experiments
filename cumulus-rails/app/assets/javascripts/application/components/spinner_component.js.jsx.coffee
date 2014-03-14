###* @jsx React.DOM ###

@app.components.SpinnerComponent = React.createClass
  propTypes:
    preset: React.PropTypes.object

  getInitialState: ->
    isShown: false
    preset: @props.preset ? app.config.spinner.tiny

  classes: ->
    React.addons.classSet
      "spinner": true
      "is-shown": @state.isShown

  componentDidMount: ->
    @spinner = new Spinner(@state.preset).spin(@refs.spinnerEl.getDOMNode())

  render: ->

    `<figure>
      { this.state.isShown ? 'shown' : 'not shown' }
      <div ref="spinnerEl" className={this.classes()}></div>
    </figure>`
