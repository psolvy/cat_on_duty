defmodule CatOnDuty.BusinessCalendar do
  @moduledoc """
    Module that's contains not business days
  """

  def get do
    %{
      # NOTE: Businex has timex inside and track name of days with default Gettext locale starting
      # from 3.7.3 (https://hexdocs.pm/timex/changelog.html#3-7-3)
      working_days: ~w[
        понедельник
        вторник
        среда
        четверг
        пятница
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
        "December 31, 2021",
        "January 3, 2022",
        "January 4, 2022",
        "January 5, 2022",
        "January 6, 2022",
        "January 7, 2022",
        "February 23, 2022",
        "March 7, 2022",
        "March 8, 2022",
        "May 2, 2022",
        "May 3, 2022",
        "May 9, 2022",
        "May 10, 2022",
        "June 13, 2022",
        "November 4, 2022",
        "January 2, 2023",
        "January 3, 2023",
        "January 4, 2023",
        "January 5, 2023",
        "January 6, 2023",
        "February 23, 2023",
        "February 24, 2023",
        "March 7, 2023",
        "March 8, 2023",
        "May 1, 2023",
        "May 8, 2023",
        "May 9, 2023",
        "June 12, 2023",
        "November 6, 2023"
      ]
    }
  end
end
