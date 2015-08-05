﻿#!/usr/bin/oscript

/////////////////////////////////////////////////////////////////////////
//
// OneScript Package Manager
// Установщик пакетов для OneScript
// Выполняется, как os-приложение в командной строке:
//
// opm install my-package.ospx
//
/////////////////////////////////////////////////////////////////////////

#Использовать cmdline
#Использовать logos

#Использовать "."

Перем Лог;

Процедура ВыполнитьКоманду(Знач Аргументы)
	
	ОбработкаКоманд = СоздатьОбработчикКоманд();
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
	
	ОбработкаКоманд.ДобавитьОписанияКоманд(Парсер);
	
	ПараметрыКоманды = Парсер.РазобратьКоманду(Аргументы);
	Если ПараметрыКоманды = Неопределено Тогда
		Сообщить("Некорректные аргументы командной строки");
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	Попытка
		ЗначенияПараметров = ПараметрыКоманды.ЗначенияПараметров;
		Если ПараметрыКоманды.Команда = "build" Тогда
			ОбработкаКоманд.ВыполнитьСборку(ЗначенияПараметров["КаталогИсходников"], ЗначенияПараметров["-mf"], ЗначенияПараметров["-out"]);
		ИначеЕсли ПараметрыКоманды.Команда = "prepare" Тогда
			ОбработкаКоманд.ПодготовитьКаталогПроекта(ЗначенияПараметров["КаталогСборкиПакета"]);
		ИначеЕсли ПараметрыКоманды.Команда = "install" Тогда
			ОбработкаКоманд.УстановитьПакет(ЗначенияПараметров["ИмяПакета"]);
		КонецЕсли;
		
	Исключение
		Лог.Отладка(ОписаниеОшибки());
		Сообщить(КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
		ЗавершитьРаботу(1);
	КонецПопытки;
	
КонецПроцедуры

/////////////////////////////////////////////////////////////////////////
// Вспомогательные функции

Функция КаталогСкрипта()
	
	Возврат (Новый Файл(ТекущийСценарий().Источник)).Путь;
	
КонецФункции

Функция СоздатьОбработчикКоманд()
	Возврат Новый ДиспетчерКомандПриложения();
КонецФункции

/////////////////////////////////////////////////////////////////////////
// Точка входа

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
Лог.УстановитьУровень(УровниЛога.Отладка);

ВыполнитьКоманду(АргументыКоманднойСтроки);