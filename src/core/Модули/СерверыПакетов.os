
Функция ИзНастроек(Знач ТекущийСерверПакетов, Знач Индекс) Экспорт
	
	Сервер = ПолучитьЗначение(ТекущийСерверПакетов, "Сервер", "");
	Порт = Число(ПолучитьЗначение(ТекущийСерверПакетов, "Порт", 80));
	ПутьНаСервере = ПолучитьЗначение(ТекущийСерверПакетов, "ПутьНаСервере", "/");
	Имя = ПолучитьЗначение(ТекущийСерверПакетов, "Имя", СтрШаблон("ДопСервер_%1", Индекс));
	РесурсПубликацииПакетов = ПолучитьЗначение(ТекущийСерверПакетов, "РесурсПубликацииПакетов", "/");
	Приоритет = Число(ПолучитьЗначение(ТекущийСерверПакетов, "Приоритет", 0));
	Авторизация = ПолучитьЗначение(ТекущийСерверПакетов, "Авторизация", "");
	ДополнительныеЗаголовки = ПолучитьЗначение(ТекущийСерверПакетов, "Заголовки", Новый Соответствие);
	Таймаут = ПолучитьЗначение(ТекущийСерверПакетов, "Таймаут", 600);
		
	Если ПустаяСтрока(Сервер) Тогда
		ВызватьИсключение СтрШаблон("Для сервера <%1> не задан адрес", Индекс);
	КонецЕсли;

	СерверПакетов = Новый СерверПакетов(Имя, Сервер, ПутьНаСервере, РесурсПубликацииПакетов,
		Порт, Приоритет, Авторизация, ДополнительныеЗаголовки, Таймаут
	);

	Возврат СерверПакетов;

КонецФункции

Функция ОсновнойСервер() Экспорт
	Возврат Новый СерверПакетов("ОсновнойСерверПакетов",
		КонстантыOpm.СерверУдаленногоХранилища,
		КонстантыOpm.ПутьВХранилище,
		КонстантыOpm.РесурсПубликацииПакетов,
		80,
		0
	);
КонецФункции

Функция ЗапаснойСервер() Экспорт
	Возврат Новый СерверПакетов("ЗапаснойСерверПакетов",
		КонстантыOpm.СерверЗапасногоХранилища,
		КонстантыOpm.ПутьВЗапасномХранилище,
		Неопределено,
		80,
		1
	);
КонецФункции

Функция ПолучитьЗначение(Знач ВходящаяСтруктура, Знач Ключ, Знач ЗначениеПоУмолчанию)

	Перем ЗначениеКлюча;

	Если Не ВходящаяСтруктура.Свойство(Ключ, ЗначениеКлюча) Тогда
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;

	Если ЗначениеКлюча = Неопределено Тогда
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;

	Возврат ЗначениеКлюча;

КонецФункции
