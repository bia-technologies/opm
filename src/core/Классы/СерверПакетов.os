Перем Лог;

Перем Имя Экспорт;
Перем Сервер Экспорт;
Перем ПутьНаСервере Экспорт;
Перем Порт Экспорт;
Перем Приоритет Экспорт;
Перем Соединение;
Перем РесурсПубликацииПакетов Экспорт;
Перем Авторизация Экспорт;
Перем ДополнительныеЗаголовки Экспорт;

Перем ПакетыХаба;

Процедура ПриСозданииОбъекта(Знач ИмяСервера, Знач АдресСервер, Знач ВходящийПутьНаСервере = "",
		Знач ВходящийРесурсПубликацииПакетов = "", Знач ВходящийПорт = 80, Знач ВходящийПриоритет = 0,
		Знач ВходящаяАвторизация = Неопределено, Знач Заголовки = Неопределено)
	
	Имя = ИмяСервера;
	Сервер = АдресСервер;
	ПутьНаСервере = ВходящийПутьНаСервере;
	Порт = ВходящийПорт;
	Приоритет = ВходящийПриоритет;
	РесурсПубликацииПакетов = ВходящийРесурсПубликацииПакетов;
	Авторизация = ВходящаяАвторизация;
	ДополнительныеЗаголовки = Заголовки;

КонецПроцедуры

Функция ПолучитьИмя() Экспорт
	Возврат Имя;
КонецФункции

Функция СерверДоступен() Экспорт
	Возврат Не Соединение = Неопределено;
КонецФункции

Функция ИнициализироватьСоединение()

	Если Не Соединение = Неопределено Тогда
		Возврат Соединение;
	КонецЕсли;
	
	Порт = ?(Порт = Неопределено, 80, Порт);
	Настройки = НастройкиOpm.ПолучитьНастройки();
	Таймаут = 60;
	Если Настройки.ИспользоватьПрокси Тогда
		НастройкиПрокси = НастройкиOpm.ПолучитьИнтернетПрокси();
		Соединение = Новый HTTPСоединение(Сервер, Порт, , , НастройкиПрокси, Таймаут);
	Иначе
		Соединение = Новый HTTPСоединение(Сервер, Порт, , , , Таймаут);
	КонецЕсли;
	
	Возврат Соединение;
	
КонецФункции

// ИмяРесурса - имя файла относительно "Сервер/ПутьВХранилище"
// Возвращает HttpОтвет или Неопределено, если запрос вернул исключение.
Функция ПолучитьРесурс(Знач ИмяРесурса) Экспорт

	Соединение = ИнициализироватьСоединение();
	Ресурс = ПутьНаСервере + ИмяРесурса;
	Запрос = Новый HTTPЗапрос(Ресурс);
	ДобавитьЗаголовки(Запрос);

	Попытка
		
		Возврат Соединение.Получить(Запрос);

	Исключение

		Лог.Ошибка(ОписаниеОшибки());
		Возврат Неопределено;

	КонецПопытки;

КонецФункции

Функция ПрочитатьФайлСпискаПакетов(Текст)
	
	ТекстовыйДокумент  = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(Текст);
	КоличествоПакетовВХабе = ТекстовыйДокумент.КоличествоСтрок();
	Для НомерСтроки = 1 По КоличествоПакетовВХабе Цикл
		ИмяПакета = СокрЛП(ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки));
		
		Если ПустаяСтрока(ИмяПакета) Тогда
			Продолжить;
		КонецЕсли;

		Если ПакетыХаба[ИмяПакета] = Неопределено Тогда
			ПакетыХаба.Вставить(ИмяПакета, Новый Массив);
		КонецЕсли;
		ПакетыХаба[ИмяПакета] = ""; // Тут должна быть строка версий
	КонецЦикла;

КонецФункции

Функция ПолучитьСписокПакетов(Ресурс)

	Ответ = ПолучитьРесурс(Ресурс);
	Если Ответ = Неопределено Тогда
		ТекстИсключения = "Ошибка подключения к зеркалу";
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;

	Если Ответ.КодСостояния <> 200 Тогда
		ТекстОтвета = Ответ.ПолучитьТелоКакСтроку();
		ТекстИсключения = СтрШаблон("Ошибка подключения к зеркалу код ответа: <%1>
		|Текст ответа: <%2>", Ответ.КодСостояния, ТекстОтвета);
		ВызватьИсключение ТекстИсключения;
	КонецЕсли;
	ТекстОтвета = Ответ.ПолучитьТелоКакСтроку();
	Ответ.Закрыть();

	Возврат ТекстОтвета;

КонецФункции

Функция ПолучитьПакеты() Экспорт

	ПакетыХаба = Новый Соответствие;

	ТекстОтвета = "";

	Попытка
		ТекстОтвета = ПолучитьСписокПакетов("list.txt");
	Исключение
		Лог.Предупреждение(
			СтрШаблон("Ошибка получения списка пакетов с хаба %1 по причине %2", 
			Имя, ОписаниеОшибки()
			)
		);
	КонецПопытки;

	ПрочитатьФайлСпискаПакетов(ТекстОтвета);
	
	Возврат ПакетыХаба;

КонецФункции

Процедура ДобавитьЗаголовки(Знач Запрос)
	
	Если ЗначениеЗаполнено(ДополнительныеЗаголовки) Тогда
		Для Каждого мЗаголовок Из ДополнительныеЗаголовки Цикл
			ДобавитьЗаголовокКЗапросу(Запрос, мЗаголовок.Ключ, мЗаголовок.Значение);
		КонецЦикла;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Авторизация) Тогда
		ДобавитьЗаголовокКЗапросу(Запрос, "Authorization", Авторизация);
	КонецЕсли;

КонецПроцедуры

Процедура ДобавитьЗаголовокКЗапросу(Знач Запрос, Знач Заголовок, Знач Значение)
	Запрос.Заголовки.Вставить(Заголовок, Значение);
КонецПроцедуры

Функция НастройкаДляВыгрузки() Экспорт

	Результат = Новый Структура;
	Результат.Вставить("Имя", Имя);
	Результат.Вставить("Сервер", Сервер);
	Результат.Вставить("ПутьНаСервере", ПутьНаСервере);
	Результат.Вставить("РесурсПубликацииПакетов", РесурсПубликацииПакетов);
	Результат.Вставить("Порт", Порт);
	Результат.Вставить("Авторизация", Авторизация);
	Результат.Вставить("Заголовки", ДополнительныеЗаголовки);
	Результат.Вставить("Приоритет", Приоритет);
	
	Возврат Результат;

КонецФункции //

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
ДополнительныеЗаголовки = Новый Соответствие;