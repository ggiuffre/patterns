String formattedDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

String formattedTime(DateTime date) =>
    "${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}";

String formattedDateTime(DateTime date) => "${formattedDate(date)}, ${formattedTime(date)}";
