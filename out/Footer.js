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
 * @param {bool} isExternal (required) Whether this component is being used externally.
 * @param {shape} router (required) React Router.
 */
const Footer = ({ isExternal, router }) => {
    return ();
}

Footer.defaultProps = {
}

Footer.propTypes = {
    isExternal: PropTypes.bool.isRequired,
    router: PropTypes.shape({
        push: PropTypes.func.isRequired
    }).isRequired
}

export default Footer;