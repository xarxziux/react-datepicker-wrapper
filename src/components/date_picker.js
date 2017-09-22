const React = require ('React');
const DatePickerMain = require ('react-datepicker');

let sendDate = () => {};

class DatePicker extends React.Component {
    
    constructor (props) {
        
        super(props);
        this.state = {
            startDate: null
        };
        
        this.handleChange = this.handleChange.bind(this);
      
    }
  
    handleChange (date) {
        
        this.setState({
            startDate: date
        });
        
        sendDate (date);
        
    }
  
    render () {
        
        return <DatePickerMain
            selected={this.state.startDate}
            onChange={this.handleChange}
        />;
      
    }
    
}

module.exports = changeEvent => {
    
    if (typeof changeEvent === 'function')
        sendDate = changeEvent;
    
    return <DatePicker />;
    
};
