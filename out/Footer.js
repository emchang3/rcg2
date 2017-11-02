/**
 * @module Footer
 * 
 * @requires react
 * @requires prop-types
 * @requires styles
 */

import React from 'react';
import PropTypes from 'prop-types';
import { authColors } from '../../common/utility/styles';

/**
 * Footer: Footer component.
 * 
 * @function
 * @param {bool} isExternal Whether this component is being used externally.
 * @param {shape} router React Router.
 */
const Footer = ({ isExternal, router }) => {
    return ();
}

Footer.propTypes = {
    isExternal: React.PropTypes.bool.isRequired,
    router: React.PropTypes.shape({
        push: React.PropTypes.func.isRequired
    }).isRequired
}

export default Footer;