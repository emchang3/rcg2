/**
 * @module Login
 * 
 * @requires react
 * @requires prop-types
 * @requires AuthErrorDisplay
 * @requires CustomLink
 * @requires FeedbackTitle
 * @requires Footer
 * @requires FormButton
 * @requires Logo
 * @requires TextInputField
 * @requires validations
 * @requires animations
 * @requires methods
 */

import React from 'react';
import PropTypes from 'prop-types';
import AuthErrorDisplay from './components/AuthErrorDisplay';
import CustomLink from '../common/components/CustomLink';
import FeedbackTitle from './components/FeedbackTitle';
import Footer from './components/Footer';
import FormButton from '../common/components/FormButton';
import Logo from '../common/components/Logo';
import TextInputField from '../common/components/TextInputField';
import { checkEmail } from '../common/utility/validations';
import { fade } from '../common/utility/animations';
import { fadeAction, getDomain, onResize, testIE11AndiOSChrome } from '../common/utility/methods';

/**
 * @class Login
 */
class Login extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            innerWidth: window.innerWidth,
            innerHeight: window.innerHeight,
            isAutofilled: false,
            passwordErrorText: '',
            passwordValue: '',
            emailErrorText: '',
            emailValue: '',
            style: {
                opacity: 0
            },
            submitButtonDisabled: true,
            timesUpdated: 0
        }
    }

    onAnyChange = () => {}

    componentDidMount = () => {}

    render() {
        return ();
    }
}

Login.propTypes = {
    router: React.PropTypes.shape({
        push: React.PropTypes.func.isRequired
    }).isRequired
}

export default Login;