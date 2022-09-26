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
		const token = req.cookies['github-jwt'];

		if (token === undefined || token === '') {
			const code = req.query.code as string;
			if (code === undefined || code === '') {
				const redirect = `https://auth.dev.mp281x.xyz/auth?scope=user:email`;
				return res.redirect(`https://github.com/login/oauth/authorize?client_id=${process.env.client_id}&redirect_uri=${redirect}`);
			}

			const githubUser = await getGithubUser({ code });
			if (githubUser.username !== 'MP281X') return res.json({ error: 'unauthorized' });

			const token = jwt.sign(githubUser, process.env.jwtKey ?? '');
			res.cookie('github-jwt', token, {
				httpOnly: true,
				sameSite: 'strict',
				secure: false,
				maxAge: 60 * 60 * 24 * 2
			});

			res.status(200);
			return res.json({ res: 'authorized' });
		} else {
			const tokenData = jwt.verify(token, process.env.jwtKey ?? '') as { username: string };
			if (tokenData.username !== 'MP281X') return res.json({ error: 'unauthorized' });
			return res.json({ res: 'authorized' });
		}
	} catch (error) {
		res.status(500);
		return res.json({ res: 'unauthorized' });
	}
});
