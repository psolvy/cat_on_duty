defmodule CatOnDuty.BusinessCalendar do
  @moduledoc """
    Module that's contains not business days
  """
  def get do
    %{
      working_days: [
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday"
      ],
      holidays: [
        "December 31, 2020",
        "January 1, 2021",
        "January 4, 2021",
        "January 5, 2021",
        "January 6, 2021",
        "January 7, 2021",
        "January 8, 2021",
        "February 22, 2021",
        "February 23, 2021",
        "March 8, 2021",
        "May 3, 2021",
        "May 4, 2021",
        "May 5, 2021",
        "May 6, 2021",
        "May 7, 2021",
        "May 10, 2021",
        "June 14, 2021",
        "November 4, 2021",
        "November 5, 2021",
        "December 31, 2021"
      ]
    }
  end
end
