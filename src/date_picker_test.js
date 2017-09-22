const React = require ('react');
const ReactDOM = require ('react-dom');
const datePicker = require ('./components/date_picker.js');

const changeEvent = ({_d}) => {
    
    /* eslint-disable no-console */
    console.log (_d);
    /* eslint-enable no-console */
    
};

const RenderMain = () => (
    
    <div>
        {datePicker (changeEvent)}
    </div>
    
);

const main = () => (
  
    ReactDOM.render (
        
        <RenderMain />,
        document.getElementById ('root')
        
    )
    
);

main();

