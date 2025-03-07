import * as vscode from 'vscode';

interface Conflict {
    start: number;
    end: number;
    current: string;
    healed: string;
    solution: string;
}

export function activate(context: vscode.ExtensionContext) {
    // Create decorations for the conflict markers
    const conflictDecoration = vscode.window.createTextEditorDecorationType({
        backgroundColor: new vscode.ThemeColor('merge.currentHeaderBackground'),
        isWholeLine: true,
    });

    // Enhanced watchers for nested PageObjects structure
    const watchers = [
        // PageObjects directory with any depth of nesting
        vscode.workspace.createFileSystemWatcher('**/PageObjects/**/**/*.py'),
        // Common naming patterns for locator files at any depth
        vscode.workspace.createFileSystemWatcher('**/*page*.py'),
        vscode.workspace.createFileSystemWatcher('**/*locator*.py'),
        vscode.workspace.createFileSystemWatcher('**/*selector*.py'),
        vscode.workspace.createFileSystemWatcher('**/*element*.py')
    ];

    // Register commands for handling locator changes
    const commands = [
        vscode.commands.registerCommand('locatorReviewer.acceptCurrent', (uri: vscode.Uri, conflict: Conflict) => {
            handleLocatorChange(uri, conflict, 'current');
        }),
        vscode.commands.registerCommand('locatorReviewer.acceptHealed', (uri: vscode.Uri, conflict: Conflict) => {
            handleLocatorChange(uri, conflict, 'healed');
        }),
        vscode.commands.registerCommand('locatorReviewer.showDiff', (uri: vscode.Uri, conflict: Conflict) => {
            showDiff(conflict);
        })
    ];

    // Add watchers and commands to subscriptions
    context.subscriptions.push(...watchers, ...commands);

    // Handle file changes
    watchers.forEach(watcher => {
        watcher.onDidChange(async (uri) => {
            const document = await vscode.workspace.openTextDocument(uri);
            if (isLocatorFile(document)) {
                handleLocatorFile(document, conflictDecoration);
            }
        });

        watcher.onDidCreate(async (uri) => {
            const document = await vscode.workspace.openTextDocument(uri);
            if (isLocatorFile(document)) {
                handleLocatorFile(document, conflictDecoration);
            }
        });
    });
}

// Enhanced locator file detection
function isLocatorFile(document: vscode.TextDocument): boolean {
    const content = document.getText();
    const filePath = document.uri.fsPath;
    
    // Check if file is in PageObjects directory structure
    const isInPageObjects = filePath.includes('PageObjects');
    
    // Common locator patterns
    const locatorPatterns = [
        /xpath\s*=\s*["'].*["']/,
        /css\s*=\s*["'].*["']/,
        /id\s*=\s*["'].*["']/,
        /_locator\s*=\s*["'].*["']/,
        /_selector\s*=\s*["'].*["']/,
        /element_\w+\s*=\s*["'].*["']/,
        /page_\w+\s*=\s*["'].*["']/
    ];

    // Check file naming patterns
    const locatorFilePatterns = [
        /page.*\.py$/i,
        /locator.*\.py$/i,
        /selector.*\.py$/i,
        /element.*\.py$/i
    ];

    return isInPageObjects || 
           locatorPatterns.some(pattern => pattern.test(content)) ||
           locatorFilePatterns.some(pattern => pattern.test(filePath));
}

async function handleLocatorFile(document: vscode.TextDocument, decoration: vscode.TextEditorDecorationType) {
    const editor = await vscode.window.showTextDocument(document);
    const conflicts = findConflicts(document.getText());

    if (conflicts.length > 0) {
        conflicts.forEach(conflict => {
            const range = new vscode.Range(
                document.positionAt(conflict.start),
                document.positionAt(conflict.end)
            );

            // Add decorations
            editor.setDecorations(decoration, [range]);

            // Add codelens for actions
            vscode.languages.registerCodeLensProvider({ scheme: 'file', pattern: '**/*.py' }, {
                provideCodeLenses(document: vscode.TextDocument): vscode.CodeLens[] {
                    const lens = new vscode.CodeLens(range, {
                        title: 'Review Locator Change',
                        command: 'locatorReviewer.showOptions',
                        arguments: [document.uri, conflict]
                    });
                    return [lens];
                }
            });

            // Show hover information
            vscode.languages.registerHoverProvider({ scheme: 'file', pattern: '**/*.py' }, {
                provideHover(doc, pos) {
                    if (range.contains(pos)) {
                        const content = new vscode.MarkdownString();
                        content.appendMarkdown(`**Locator Change Detected**\n\n`);
                        content.appendMarkdown(`Solution: ${conflict.solution}\n\n`);
                        content.appendMarkdown(`[Accept Current](command:locatorReviewer.acceptCurrent?${encodeURIComponent(JSON.stringify([doc.uri, conflict]))})\n`);
                        content.appendMarkdown(`[Accept Healed](command:locatorReviewer.acceptHealed?${encodeURIComponent(JSON.stringify([doc.uri, conflict]))})\n`);
                        content.appendMarkdown(`[Show Diff](command:locatorReviewer.showDiff?${encodeURIComponent(JSON.stringify([doc.uri, conflict]))})`);
                        content.isTrusted = true;
                        return new vscode.Hover(content, range);
                    }
                    return null;
                }
            });
        });

        // Show notification
        vscode.window.showInformationMessage(
            `${conflicts.length} locator change(s) detected. Hover over the highlighted areas to review.`
        );
    }
}

function findConflicts(text: string): Conflict[] {
    const conflicts: Conflict[] = [];
    const lines = text.split('\n');
    let i = 0;

    while (i < lines.length) {
        if (lines[i].startsWith('<<<<<<< Current')) {
            const start = i;
            let current = '';
            let healed = '';
            let solution = '';

            i++;
            // Get current version
            while (i < lines.length && !lines[i].startsWith('=======')) {
                current += lines[i] + '\n';
                i++;
            }
            i++;

            // Get healed version
            while (i < lines.length && !lines[i].startsWith('>>>>>>> Healed')) {
                if (lines[i].startsWith('# Solution: ')) {
                    solution = lines[i].substring('# Solution: '.length);
                } else {
                    healed += lines[i] + '\n';
                }
                i++;
            }

            conflicts.push({
                start: start,
                end: i,
                current: current.trim(),
                healed: healed.trim(),
                solution: solution
            });
        }
        i++;
    }
    return conflicts;
}

async function resolveConflict(editor: vscode.TextEditor, conflict: Conflict, choice: 'current' | 'healed') {
    const edit = new vscode.WorkspaceEdit();
    const range = new vscode.Range(
        editor.document.positionAt(conflict.start),
        editor.document.positionAt(conflict.end + 1)
    );

    const newText = choice === 'current' ? conflict.current : conflict.healed;
    edit.replace(editor.document.uri, range, newText + '\n');
    await vscode.workspace.applyEdit(edit);
}

async function showDiff(conflict: Conflict) {
    const uri = vscode.Uri.parse('untitled:Locator Change.diff');
    const doc = await vscode.workspace.openTextDocument(uri);
    const edit = new vscode.WorkspaceEdit();
    const content = `Current:\n${conflict.current}\n\nHealed:\n${conflict.healed}\n\nSolution: ${conflict.solution}`;
    edit.insert(uri, new vscode.Position(0, 0), content);
    await vscode.workspace.applyEdit(edit);
    await vscode.window.showTextDocument(doc, { preview: false });
} 