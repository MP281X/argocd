import express, { Request, Response, NextFunction } from 'express';
import axios from 'axios';
import jwt from 'jsonwebtoken';
import cookieParser from 'cookie-parser';
import * as dotenv from 'dotenv';

dotenv.config();
const app = express();
app.use(cookieParser());
app.listen(3000, () => console.log(`Auth server running`));

async function getGithubUser({ code }: { code: string }) {
	const githubToken = await axios
		.post(`https://github.com/login/oauth/access_token?client_id=${process.env.client_id}&client_secret=${process.env.client_secret}&code=${code}`)
		.then((res) => res.data)
		.catch((error) => {
			throw error;
		});

	const accessToken = new URLSearchParams(githubToken).get('access_token');
	const userData = await axios
		.get('https://api.github.com/user', { headers: { Authorization: `Bearer ${accessToken}` } })
		.then((res) => res.data)
		.catch((error) => {
			throw error;
		});

	return { username: userData.login };
}

app.get('/auth', async (req: Request, res: Response) => {
	try {
		const code = req.query.code as string;

		// check if there is a github token in the url, if not redirect to the github auth page
		if (code === undefined || code === '') {
			console.log('redirected to the github auth page');
			const redirect = `https://auth.dev.mp281x.xyz/auth?scope=user:email`;
			return res.redirect(`https://github.com/login/oauth/authorize?client_id=${process.env.client_id}&redirect_uri=${redirect}`);
		}

		// check if the token is valid and get the user data
		const githubUser = await getGithubUser({ code });

		// check if the user has permission
		if (githubUser.username !== 'MP281X') return res.json({ error: 'unauthorized' });

		// add the cookie with the token to the browser
		const token = jwt.sign(githubUser, process.env.jwtKey ?? '');
		res.cookie('github-jwt', token, {
			httpOnly: true,
			domain: 'https://grafana.dev.mp281x.xyz',
			secure: false,
			maxAge: 60 * 60 * 24 * 2
		});
		console.log('added the cookie to the browser');

		// return a success message
		console.log('authorized');
		res.status(200);
		return res.json({ res: 'authorized' });
	} catch (error) {
		console.log(error);

		// return a error message
		res.status(500);
		return res.json({ res: 'unauthorized' });
	}
});

app.all('/', async (req: Request, res: Response) => {
	try {
		const token = req.cookies['github-jwt'];
		console.log(req.cookies);
		console.log(token);

		// if there isn't a token redirect to the auth page
		if (token === undefined || token === '') {
			console.log('token not found');
			return res.redirect(302, 'https://auth.dev.mp281x.xyz/auth');
		}

		// check if the token is valid
		const tokenData = jwt.verify(token, process.env.jwtKey ?? '') as { username: string };

		// check if the user has the permission
		if (tokenData.username !== 'MP281X') return res.json({ error: 'unauthorized' });

		// redirect to the protected page
		console.log('authorized');
		return res.sendStatus(200);
	} catch (error) {
		console.log(error);

		// return a error message
		return res.json({ res: 'unauthorized' });
	}
});
