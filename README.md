# Cabinet Doors E-commerce Application

A full-featured e-commerce application for custom cabinet doors, built with Ruby on Rails and React.

## Features

- Product catalog with customizable cabinet doors
- Shopping cart and checkout process
- Stripe payment integration
- Order management system
- Admin dashboard
- Email notifications
- Shipping calculation

## Technology Stack

- Ruby 3.3.0
- Rails 8.0.1
- React 18
- PostgreSQL
- Stripe for payments
- AWS S3 for file storage
- Heroku for hosting

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/cabinet_doors.git
   cd cabinet_doors
   ```

2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```

3. Set up the database:
   ```bash
   rails db:create db:migrate db:seed
   ```

4. Set up environment variables:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. Start the development server:
   ```bash
   ./bin/dev
   ```

## Testing

The application uses RSpec for backend tests and Cypress for end-to-end testing.

Run backend tests:
```bash
bundle exec rspec
```

Run Cypress tests:
```bash
yarn cypress:open  # For interactive mode
yarn cypress:run   # For headless mode
```

## Deployment

The application is configured for deployment to Heroku. Make sure you have the Heroku CLI installed.

1. Create a new Heroku application:
   ```bash
   heroku create your-app-name
   ```

2. Add required buildpacks:
   ```bash
   heroku buildpacks:add heroku/nodejs
   heroku buildpacks:add heroku/ruby
   ```

3. Configure environment variables:
   ```bash
   heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
   heroku config:set STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   heroku config:set STRIPE_SECRET_KEY=your_stripe_secret_key
   # Add other required environment variables
   ```

4. Deploy the application:
   ```bash
   git push heroku main
   ```

5. Set up the database:
   ```bash
   heroku run rails db:migrate
   heroku run rails db:seed
   ```

## Environment Variables

The following environment variables are required:

- `RAILS_MASTER_KEY`: Rails master key for credentials
- `DATABASE_URL`: PostgreSQL database URL (set automatically by Heroku)
- `STRIPE_PUBLISHABLE_KEY`: Stripe publishable key
- `STRIPE_SECRET_KEY`: Stripe secret key
- `AWS_ACCESS_KEY_ID`: AWS access key for S3
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for S3
- `AWS_BUCKET`: AWS S3 bucket name
- `SMTP_ADDRESS`: SMTP server address
- `SMTP_PORT`: SMTP server port
- `SMTP_DOMAIN`: SMTP domain
- `SMTP_USERNAME`: SMTP username
- `SMTP_PASSWORD`: SMTP password
- `APP_HOST`: Application host domain

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.
