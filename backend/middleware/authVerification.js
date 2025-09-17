import { auth } from "express-oauth2-jwt-bearer";

const jwtCheck = auth({
    audience: process.env.AUTH0_AUDIENCE,
    issuer: `https://${process.env.AUTH0_DOMAIN}/`,
    tokenSigningAlg: 'RS256'
});

export { jwtCheck };