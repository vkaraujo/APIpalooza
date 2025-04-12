# APIpalooza

![image](https://github.com/user-attachments/assets/9bd0b841-ab45-48b9-9c84-3d2762f8c507)


**APIpalooza** is a fun Ruby on Rails project designed to showcase API integration skills across multiple external services. The goal was to experiment with a variety of public APIs, present each one in a clean and interactive interface, and ensure consistent design, responsiveness, and user experience throughout the app.

While the project draws visual inspiration from the energy of a music festival, the core objective is to demonstrate proficiency with Rails, Hotwire, Tailwind CSS, and HTTP client integrations.


## 🚀 Technologies Used

- **Ruby on Rails 7**
- **Hotwire (Turbo + Stimulus)**
- **Tailwind CSS**
- **HTTParty**

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
