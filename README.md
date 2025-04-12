# APIpalooza
[![CI](https://github.com/vkaraujo/APIpalooza/actions/workflows/ci.yml/badge.svg)](https://github.com/vkaraujo/APIpalooza/actions)
![Coverage](https://img.shields.io/badge/Coverage-89.31%25-brightgreen)
![Ruby](https://img.shields.io/badge/Ruby-3.2.4-red?logo=ruby)
![Rails](https://img.shields.io/badge/Rails-7.1.5.1-red?logo=rubyonrails)
![Last Commit](https://img.shields.io/github/last-commit/vkaraujo/APIpalooza)
[![Deploy Status](https://img.shields.io/badge/Render-Deployed-3c873a?style=flat&logo=render)](https://apipalooza.onrender.com)

**Live app:** [https://apipalooza.onrender.com](https://apipalooza.onrender.com)
![image](https://github.com/user-attachments/assets/9bd0b841-ab45-48b9-9c84-3d2762f8c507)


**APIpalooza** is a fun Ruby on Rails project designed to showcase API integration skills across multiple external services. The goal was to experiment with a variety of public APIs, present each one in a clean and interactive interface, and ensure consistent design, responsiveness, and user experience throughout the app.

While the project draws visual inspiration from the energy of a music festival, the core objective is to demonstrate proficiency with Rails, Hotwire, Tailwind CSS, and HTTP client integrations.

#### 🛠️ Architecture & Tech Used

- **Rails 7.1** with **Hotwire/Turbo**
- **Tailwind CSS**
- **HTTParty**
- **Sidekiq** for background jobs (`WeatherRefreshAllJob`)
- **Redis** for job queue and caching
- **RSpec** with full controller & service specs
- **WebMock** for external API stubbing
- **SimpleCov** for code coverage
- **CI/CD:** GitHub Actions (runs tests on push & PR)
- **Deploy:** [Render](https://render.com/) — Free tier

## ⚙️ Backend Features by API

This app demonstrates different backend techniques across each API integration to showcase versatility and practical Rails patterns:

| API         | Features & Techniques Used |
|-------------|-----------------------------|
| **Weather** | - Database snapshot caching (1 entry per city)  <br>- Background job to refresh data hourly using Sidekiq & sidekiq-scheduler |
| **Recipes** | - External API integration with API key  <br>- Rails low-level caching (`Rails.cache`) for search and details |
| **Books**   | - Basic HTTP API fetcher with graceful fallback  <br>- Service object pattern |
| **Jokes**   | - Simple service-based fetcher with category param handling |
| **Numbers** | - Service object with validation logic  <br>- Custom warning messages per input type  <br>- "🎲 Surprise Me" feature |
| **Trivia**  | - Rate limiting with cache to throttle excessive API requests  <br>- Turbo stream updates with detailed feedback |
| **YouTube** | - Integration with Google Cloud (YouTube Data API)  <br>- Service object pattern with API key handling |

Each controller and service was written with clarity and testability in mind, and all core logic is covered by RSpec tests.

## 🚀 Render Deployment Strategy

To make this app deployable on [Render's free tier](https://render.com), we made a few key adjustments:

- **ActiveJob runs inline in production**  
  Background jobs are executed immediately, instead of requiring a Sidekiq worker.

- **Sidekiq Scheduler is disabled in production**  
  Our job schedule is defined in `config/sidekiq_schedule.yml`, but it's only loaded in development to avoid breaking free-tier hosting.

- **Manual Rake Task as an Alternative to Cron**  
  Instead of automatic job scheduling, you can manually refresh weather data anytime using the command below:

```bash
bin/rails weather:refresh_all
```

## ✅ Test Coverage

This project uses [SimpleCov](https://github.com/simplecov-ruby/simplecov) to measure code coverage in tests.

![image](https://github.com/user-attachments/assets/450c0636-bde3-4aee-a5c1-449147191ae8)


### 🧪 Running with Coverage Report

To generate a coverage report, run:

```bash
COVERAGE=true bundle exec rspec
```
After the tests run, open the file coverage/index.html in your browser to view a detailed report.
This helps identify which parts of the application are not yet covered by tests.

## ✅ Continuous Integration (CI)

This project uses **GitHub Actions** to automatically run tests on every push and pull request.

The CI workflow ensures that the codebase remains stable and that all RSpec tests pass before new changes are merged.

**CI Features:**

- ⏱️ Runs on every `push` and `pull_request`
- ✅ Executes the full test suite using `RSpec`
- ❌ Fails early if any test or setup step fails

You can view workflow runs in the [Actions tab](https://github.com/vkaraujo/APIpalooza/actions).

## 🌐 Integrated APIs

Each API has its own dedicated page and feature. The following APIs are used:

| API | Description | Documentation |
|-----|-------------|---------------|
| [OpenWeatherMap](https://openweathermap.org/api) | Current weather and forecast by city name | [Docs](https://openweathermap.org/current) |
| [Spoonacular](https://spoonacular.com/food-api) | Recipe search by ingredient | [Docs](https://spoonacular.com/food-api/docs) |
| [Open Library](https://openlibrary.org/developers/api) | Book search by keyword or author | [Docs](https://openlibrary.org/dev/docs/api/search) |
| [JokeAPI](https://jokeapi.dev) | Programming jokes, dad jokes, dark humor and more | [Docs](https://jokeapi.dev) |
| [Numbers API](http://numbersapi.com/) | Trivia, math, year, and date facts about numbers | [Docs](http://numbersapi.com/#42) |
| [Open Trivia DB](https://opentdb.com/api_config.php) | Random trivia questions by difficulty and type | [Docs](https://opentdb.com/api_config.php) |
| [YouTube Data API](https://developers.google.com/youtube/v3) | Video search and embedding | [Docs](https://developers.google.com/youtube/v3) |

---

### ⏰ Running Sidekiq with Scheduled Jobs

To enable scheduled background jobs like weather data refreshing, use the following command to start Sidekiq with the custom configuration:

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

## About the Project

This project was built as a personal exploration of working with external APIs in Rails. The emphasis was on building small, self-contained features for each API while maintaining a consistent structure and design language. It also served as an opportunity to experiment with Hotwire and Tailwind in a playful but technically grounded way.
