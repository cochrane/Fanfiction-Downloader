Fanfiction Downloader
=====================

Der Fanfiction Downloader ist ein Mac OS X Programm um Geschichten auf [FanFiction.net][] zu verwalten und auf Kindle zu schicken. Der Update-Button sucht automatisch, welche Geschichten geändert wurden seit dem letzten Versenden, und schickt sie per E-mail an [Amazon][]. Sobald sie dort verarbeitet wurden, werden sie bei nächster Gelegenheit auf den Kindle heruntergeladen.

Das Projekt ist stark inspiriert von [cryzeds Lemon][lemon], ein Python Skript. Im Gegensatz dazu gibt es hier ein grafisches Interface, und alles ist in Objective C geschrieben. Das einzige, was ich übernommen habe (mit Anpassungen) war das HTML-Template.

Anleitung
---------

1.	Die neueste Version kann unter "Downloads" heruntergeladen werden.
2.	Beim ersten Start wird das Programm nach der E-mail-Adresse des Kindles und der Absenderadresse fragen. Die Absenderadresse muss in Mail bekannt sein, denn das Programm schickt die E-mails über Mail.
3.	Geschichten kann man über den "+"-Button hinzufügen, oder in dem man Links per Drag-and-Drop ins Hauptfenster zieht.
4.	Der Update-Button (oder das entsprechende Menü-Item) sorgen dann dafür, dass die Emails gesendet werden.

Es ist auch möglich, die stories.ini von Lemon hier zu importieren. Da dieses Tool aber andere Arten verwendet, um herauszufinden, wann sich eine Geschichte geändert hat, müssen hier alle Geschichten anfangs noch mal neu gesendet werden.

Hinweis: Das Programm benötigt Mac OS X 10.7 "Lion" oder neuer.

Mögliche Probleme
-----------------

Unter Lion verhindert das Betriebssystem standardmäßig das Ausführen heruntergeladener Programme, inklusive diesem hier, so lange sie nicht signiert sind. Um darum herumzukommen, kann man dieses Feature entweder deaktivieren, oder auf das Programm rechtsklicken und "Öffnen" auswählen. Dies ist nur einmal nötig, danach öffnet sich dieses Programm jedes Mal ohne Probleme.

Die meisten Geschichten sollten gut funktionieren. Die, die Probleme verursachen, sind daher für mich besonders interessant. Bitte informiert mich über die "Issues"-Funktion, am besten mit der URL der Geschichte!

Ideen für die Zukunft
---------------------

Ich bin für alle Vorschläge offen, um das Programm weiterzuentwickeln. Derzeit auf meiner Liste:

*	Korrektes signieren und Sandboxing. Dafür bräuchte ich ein (kostenpflichtiges) Apple Entwicklerzertifikat.
*	iCloud Synchronisierung für Einstellungen und die Liste der Geschichten (das würde bedeuten, dass das Programm im App Store sein müsste)
*	Ein eigenes Icon
*	Unterstützung für mehr Webseiten (welche?)

Bitte sendet alle Probleme und Vorschläge mittels dem "Issues"-Featuer auf dieser Webseite.
[FanFiction.net]: http://fanfiction.net/
[Amazon]: http://amazon.de/
[lemon]: https://github.com/cryzed/lemon
[issues]: https://github.com/cochrane/Fanfiction-Downloader/issues