﻿/////////////////////////////////////////////////////////////////////////
//
// OneScript Package Manager
// Модуль сборки архива пакета
//
/////////////////////////////////////////////////////////////////////////

#Использовать tempfiles

Перем РабочийКаталог;
Перем ВремКаталогСборки;

Процедура СобратьПакет(Знач КаталогИсходников, Знач ФайлМанифеста, Знач ВыходнойКаталог) Экспорт

	РабочийКаталог = КаталогИсходников;
	
	Попытка
		
		Если ВыходнойКаталог = Неопределено Тогда
			ВыходнойКаталог = ТекущийКаталог();
		КонецЕсли;
		
		Сообщить("Начинаю сборку в каталоге " + РабочийКаталог);
		УстановитьТекущийКаталог(РабочийКаталог);
		УточнитьФайлМанифеста(ФайлМанифеста);
		Манифест = ПрочитатьМанифест(ФайлМанифеста);
		СобратьПакетВКаталогеСборки(Манифест, ВыходнойКаталог);
		
		Сообщить("Сборка пакета завершена");
		
	Исключение
		
		ВременныеФайлы.Удалить();
		ВызватьИсключение;
		
	КонецПопытки;

	ВременныеФайлы.Удалить();
	
КонецПроцедуры

Процедура УточнитьФайлМанифеста(ФайлМанифеста)
	
	Если ФайлМанифеста = Неопределено Тогда
		
		ФайлОбъект = Новый Файл("package-def.os");
		Если ФайлОбъект.Существует() и ФайлОбъект.ЭтоФайл() Тогда
			Сообщить("Найден файл манифеста");
			ФайлМанифеста = ФайлОбъект.ПолноеИмя;
		Иначе
			ВызватьИсключение "Не определен манифест пакета";
		КонецЕсли;
	Иначе
		Сообщить("Использую файл манифеста " + ФайлМанифеста);
	КонецЕсли;
	
КонецПроцедуры

Функция ПрочитатьМанифест(Знач ФайлМанифеста)
	
	ОписаниеПакета = Новый ОписаниеПакета();
	Сообщить("Загружаю описание пакета...");
	Манифест = ЗагрузитьСценарий(ФайлМанифеста);
	Манифест.ЗаполнитьОписаниеПакета(ОписаниеПакета);
	Сообщить("Описание пакета прочитано");
	
	Возврат ОписаниеПакета;
	
КонецФункции

Процедура СобратьПакетВКаталогеСборки(Знач Манифест, Знач ВыходнойКаталог)
	
	ВремКаталогСборки = ВременныеФайлы.СоздатьКаталог();
	
	СвойстваПакета = Манифест.Свойства();
	
	ФайлАрхива = Новый Файл(ОбъединитьПути(ВыходнойКаталог, СвойстваПакета.Имя + ".ospx"));
	Архив = Новый ЗаписьZIPФайла(ФайлАрхива.ПолноеИмя);
	
	ДобавитьОписаниеМетаданныхПакета(Архив, Манифест);
	ДобавитьФайлыПакета(Архив, Манифест);
	ДобавитьОписаниеБиблиотеки(Архив, Манифест);
	Архив.Записать();
	
КонецПроцедуры

Процедура ДобавитьОписаниеМетаданныхПакета(Знач Архив, Знач Манифест);
	
	ПутьМанифеста = ОбъединитьПути(ВремКаталогСборки, "opm-metadata.xml");
	Запись = Новый ЗаписьXML;
	Запись.ОткрытьФайл(ПутьМанифеста);
	Запись.ЗаписатьОбъявлениеXML();
	Запись.ЗаписатьНачалоЭлемента("opm-metadata");
	Запись.ЗаписатьСоответствиеПространстваИмен("", "http://oscript.io/schemas/opm-metadata/1.0");
	
	ЗаписатьСвойстваПакета(Запись, Манифест);
	ЗаписатьЗависимостиПакета(Запись, Манифест);
	
	Запись.ЗаписатьКонецЭлемента();
	Запись.Закрыть();
	
	Архив.Добавить(ПутьМанифеста);
	Сообщить("Записаны метаданные пакета");
	
КонецПроцедуры

Процедура ДобавитьОписаниеБиблиотеки(Знач Архив, Знач Манифест)
	
	Сообщить("Формирую определения модулей пакета (lib.config)");
	
	ПутьКонфигурацииПакета = ОбъединитьПути(ВремКаталогСборки, "lib.config");
	Запись = Новый ЗаписьXML;
	Запись.ОткрытьФайл(ПутьКонфигурацииПакета);
	Запись.ЗаписатьОбъявлениеXML();
	Запись.ЗаписатьНачалоЭлемента("package-def");
	Запись.ЗаписатьСоответствиеПространстваИмен("", "http://oscript.io/schemas/lib-config/1.0");
	
	Модули = Манифест.ВсеМодулиПакета();
	Для Каждого ОписаниеМодуля Из Модули Цикл
		Если ОписаниеМодуля.Тип = Манифест.ТипыМодулей.Класс Тогда
			Запись.ЗаписатьНачалоЭлемента("class");
		Иначе
			Запись.ЗаписатьНачалоЭлемента("module");
		КонецЕсли;
		
		ФайлМодуля = Новый Файл(ОписаниеМодуля.Файл);
		Если Не ФайлМодуля.Существует() Тогда
			Сообщить("ПРЕДУПРЕЖДЕНИЕ: Файл модуля " + ОписаниеМодуля.Файл + " не обнаружен.");
		КонецЕсли;
		
		Запись.ЗаписатьАтрибут("name", ОписаниеМодуля.Идентификатор);
		Запись.ЗаписатьАтрибут("file", ОписаниеМодуля.Файл);
		Запись.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
	Запись.ЗаписатьКонецЭлемента();
	Запись.Закрыть();
	
	Архив.Добавить(ПутьКонфигурацииПакета);
	Сообщить("Записаны определения модулей пакета");
	
КонецПроцедуры

Процедура ЗаписатьСвойстваПакета(Знач Запись, Знач Манифест)
	СоответствиеИменСвойств = Новый Соответствие;
	СоответствиеИменСвойств.Вставить("Имя"   , "name");
	СоответствиеИменСвойств.Вставить("Версия", "version");
	СоответствиеИменСвойств.Вставить("Автор" , "author");
	СоответствиеИменСвойств.Вставить("Описание"   , "description");
	СоответствиеИменСвойств.Вставить("АдресАвтора", "author-email");
	СоответствиеИменСвойств.Вставить("ВерсияСреды", "engine-version");
	СоответствиеИменСвойств.Вставить("ТочкаВхода" , "app-entry");
	
	СвойстваПакета = Манифест.Свойства();
	
	Для Каждого КлючИЗначение Из СвойстваПакета Цикл
		
		Если Не ЗначениеЗаполнено(КлючИЗначение.Значение) Тогда
			Продолжить;
		КонецЕсли;
		
		СинонимСвойства = СоответствиеИменСвойств[КлючИЗначение.Ключ];
		Если СинонимСвойства = Неопределено Тогда
			ИмяЭлемента = КлючИЗначение.Ключ;
		Иначе
			ИмяЭлемента = СинонимСвойства;
		КонецЕсли;
		
		Запись.ЗаписатьНачалоЭлемента(ИмяЭлемента);
		Запись.ЗаписатьТекст(XMLСтрока(КлючИЗначение.Значение));
		Запись.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаписатьЗависимостиПакета(Знач Запись, Знач Манифест)
	
	Зависимости = Манифест.Зависимости();
	Если Зависимости.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Зависимость Из Зависимости Цикл
		Запись.ЗаписатьНачалоЭлемента("depends-on");
		Запись.ЗаписатьАтрибут("name", Зависимость.ИмяПакета);
		Если Не ПустаяСтрока(Зависимость.МинимальнаяВерсия) Тогда
			Запись.ЗаписатьАтрибут("version", Зависимость.МинимальнаяВерсия);
		КонецЕсли;
		Если Не ПустаяСтрока(Зависимость.МаксимальнаяВерсия) Тогда
			Запись.ЗаписатьАтрибут("version-max", Зависимость.МаксимальнаяВерсия);
		КонецЕсли;
		Запись.ЗаписатьКонецЭлемента();
	КонецЦикла;
	
КонецПроцедуры

Процедура ДобавитьФайлыПакета(Знач Архив, Знач Манифест)
	
	ВключаемыеФайлы = Манифест.ВключаемыеФайлы();
	Если ВключаемыеФайлы.Количество() = 0 Тогда
		Сообщить("Не определены включаемые файлы");
		Возврат;
	КонецЕсли;
	
	Для Каждого ВключаемыйФайл Из ВключаемыеФайлы Цикл
		Сообщить("Добавляем файл: " + ВключаемыйФайл);
		Архив.Добавить(ВключаемыйФайл, РежимСохраненияПутейZIP.СохранятьОтносительныеПути, РежимОбработкиПодкаталоговZIP.ОбрабатыватьРекурсивно);
	КонецЦикла;
	
КонецПроцедуры
